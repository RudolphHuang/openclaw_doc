# Agent Memory tRPC Router

基于 Claude Code 文本索引记忆方案实现的 Agent 记忆系统接口。

## 概述

- **路由名称**: `agentMemory`
- **文件位置**: `src/server/routers/lambda/agentMemory.ts`
- **数据库表**: 
  - `agent_memory_index` - 记忆索引表
  - `agent_memories` - 记忆条目表

## 核心概念

### 记忆类型 (MemoryType)

| 类型 | 说明 | 示例 |
|------|------|------|
| `user` | 用户画像/偏好 | 用户是数据科学家，关注可观测性 |
| `feedback` | 行为指导/反馈 | 用户不喜欢使用表情符号 |
| `project` | 进行中的工作上下文 | 正在开发认证模块，3月发布 |
| `reference` | 外部资源指针 | Bug 跟踪在 Linear 项目 INGEST |

### 固定 Agent ID

当前角色系统暂不开发，所有记忆统一使用固定值：
```typescript
const DEFAULT_AGENT_ID = 'default_agent';
```

## tRPC Router 定义

```typescript
import { z } from 'zod';
import { authedProcedure, router } from '@/libs/trpc/lambda';
import { serverDatabase } from '@/libs/trpc/lambda/middleware';

const agentMemoryProcedure = authedProcedure
  .use(serverDatabase)
  .use(async (opts) => {
    const { ctx } = opts;
    return opts.next({
      ctx: {
        agentMemoryModel: new AgentMemoryModel(ctx.serverDB, ctx.userId),
        agentMemoryIndexModel: new AgentMemoryIndexModel(ctx.serverDB, ctx.userId),
      },
    });
  });

export const agentMemoryRouter = router({
  // 查询接口
  getMemories: agentMemoryProcedure
    .input(
      z.object({
        category: z.enum(['user', 'feedback', 'project', 'reference']).optional(),
        search: z.string().optional(),
        isActive: z.boolean().optional(),
      })
    )
    .query(async ({ input, ctx }) => {
      return ctx.agentMemoryModel.query({
        agentId: DEFAULT_AGENT_ID,
        ...input,
      });
    }),

  getMemory: agentMemoryProcedure
    .input(z.object({ id: z.string() }))
    .query(async ({ input, ctx }) => {
      return ctx.agentMemoryModel.findById(input.id);
    }),

  getMemoryIndex: agentMemoryProcedure
    .query(async ({ ctx }) => {
      // 返回记忆索引列表（供 LLM 使用）
      return ctx.agentMemoryIndexModel.queryByAgentId(DEFAULT_AGENT_ID);
    }),

  // 创建接口
  createMemory: agentMemoryProcedure
    .input(
      z.object({
        category: z.enum(['user', 'feedback', 'project', 'reference']),
        title: z.string().min(1).max(255),
        content: z.string().min(1),
        description: z.string().max(500).optional(),
        sourceSessionId: z.string().optional(),
        sourceMessageIds: z.array(z.string()).optional(),
      })
    )
    .mutation(async ({ input, ctx }) => {
      const entry = await ctx.agentMemoryModel.create({
        agentId: DEFAULT_AGENT_ID,
        ...input,
      });
      
      // 自动创建索引记录
      await ctx.agentMemoryIndexModel.create({
        agentId: DEFAULT_AGENT_ID,
        entryId: entry.id,
        category: input.category,
        title: input.title,
        description: input.description || input.content.slice(0, 100),
      });
      
      return entry;
    }),

  // 更新接口
  updateMemory: agentMemoryProcedure
    .input(
      z.object({
        id: z.string(),
        value: z.object({
          category: z.enum(['user', 'feedback', 'project', 'reference']).optional(),
          title: z.string().min(1).max(255).optional(),
          content: z.string().min(1).optional(),
          description: z.string().max(500).optional(),
          isActive: z.boolean().optional(),
        }),
      })
    )
    .mutation(async ({ input, ctx }) => {
      const result = await ctx.agentMemoryModel.update(input.id, input.value);
      
      // 同步更新索引
      if (input.value.title || input.value.description || input.value.category) {
        await ctx.agentMemoryIndexModel.updateByEntryId(input.id, {
          category: input.value.category,
          title: input.value.title,
          description: input.value.description,
        });
      }
      
      return result;
    }),

  // 删除接口
  deleteMemory: agentMemoryProcedure
    .input(z.object({ id: z.string() }))
    .mutation(async ({ input, ctx }) => {
      // 先删除索引
      await ctx.agentMemoryIndexModel.deleteByEntryId(input.id);
      // 再删除条目
      return ctx.agentMemoryModel.delete(input.id);
    }),

  // 批量操作
  batchDeleteMemories: agentMemoryProcedure
    .input(z.object({ ids: z.array(z.string()) }))
    .mutation(async ({ input, ctx }) => {
      await ctx.agentMemoryIndexModel.deleteByEntryIds(input.ids);
      return ctx.agentMemoryModel.batchDelete(input.ids);
    }),

  // 统计
  countMemories: agentMemoryProcedure
    .input(
      z.object({
        category: z.enum(['user', 'feedback', 'project', 'reference']).optional(),
      }).optional()
    )
    .query(async ({ input, ctx }) => {
      return ctx.agentMemoryModel.count({
        agentId: DEFAULT_AGENT_ID,
        ...input,
      });
    }),
});

export type AgentMemoryRouter = typeof agentMemoryRouter;
```

## 数据库 Model 定义

### AgentMemoryModel

```typescript
// packages/database/src/models/agentMemory.ts
export class AgentMemoryModel {
  private userId: string;
  private db: LobeChatDatabase;

  constructor(db: LobeChatDatabase, userId: string) {
    this.userId = userId;
    this.db = db;
  }

  // 查询记忆列表
  query = async (params: {
    agentId: string;
    category?: string;
    search?: string;
    isActive?: boolean;
  }) => {
    const { agentId, category, search, isActive } = params;
    
    return this.db.query.agentMemories.findMany({
      where: and(
        eq(agentMemories.userId, this.userId),
        eq(agentMemories.agentId, agentId),
        category ? eq(agentMemories.category, category) : undefined,
        isActive !== undefined ? eq(agentMemories.isActive, isActive) : undefined,
        search ? like(agentMemories.title, `%${search}%`) : undefined,
      ),
      orderBy: [desc(agentMemories.updatedAt)],
    });
  };

  // 根据 ID 查找
  findById = async (id: string) => {
    return this.db.query.agentMemories.findFirst({
      where: and(
        eq(agentMemories.id, id),
        eq(agentMemories.userId, this.userId),
      ),
    });
  };

  // 创建记忆
  create = async (data: NewAgentMemory) => {
    const [result] = await this.db
      .insert(agentMemories)
      .values({
        ...data,
        userId: this.userId,
        id: idGenerator('agent_memory'),
      })
      .returning();
    return result;
  };

  // 更新记忆
  update = async (id: string, data: Partial<AgentMemoryItem>) => {
    const [result] = await this.db
      .update(agentMemories)
      .set({
        ...data,
        updatedAt: new Date(),
      })
      .where(and(eq(agentMemories.id, id), eq(agentMemories.userId, this.userId)))
      .returning();
    return result;
  };

  // 删除记忆
  delete = async (id: string) => {
    return this.db
      .delete(agentMemories)
      .where(and(eq(agentMemories.id, id), eq(agentMemories.userId, this.userId)));
  };

  // 批量删除
  batchDelete = async (ids: string[]) => {
    return this.db
      .delete(agentMemories)
      .where(and(eq(agentMemories.userId, this.userId), inArray(agentMemories.id, ids)));
  };

  // 统计数量
  count = async (params: { agentId: string; category?: string }) => {
    const [result] = await this.db
      .select({ count: count() })
      .from(agentMemories)
      .where(
        and(
          eq(agentMemories.userId, this.userId),
          eq(agentMemories.agentId, params.agentId),
          params.category ? eq(agentMemories.category, params.category) : undefined,
        ),
      );
    return result.count;
  };
}
```

### AgentMemoryIndexModel

```typescript
// packages/database/src/models/agentMemoryIndex.ts
export class AgentMemoryIndexModel {
  private userId: string;
  private db: LobeChatDatabase;

  constructor(db: LobeChatDatabase, userId: string) {
    this.userId = userId;
    this.db = db;
  }

  // 查询某 Agent 的所有索引
  queryByAgentId = async (agentId: string) => {
    return this.db.query.agentMemoryIndex.findMany({
      where: and(
        eq(agentMemoryIndex.userId, this.userId),
        eq(agentMemoryIndex.agentId, agentId),
        eq(agentMemoryIndex.isActive, true),
      ),
      orderBy: [desc(agentMemoryIndex.lastAccessedAt)],
    });
  };

  // 创建索引
  create = async (data: {
    agentId: string;
    entryId: string;
    category: string;
    title: string;
    description?: string;
  }) => {
    const [result] = await this.db
      .insert(agentMemoryIndex)
      .values({
        ...data,
        userId: this.userId,
        id: idGenerator('agent_memory_idx'),
        isActive: true,
        accessCount: 0,
        lastAccessedAt: new Date(),
      })
      .returning();
    return result;
  };

  // 更新索引（通过 entryId）
  updateByEntryId = async (entryId: string, data: Partial<AgentMemoryIndexItem>) => {
    return this.db
      .update(agentMemoryIndex)
      .set({
        ...data,
        updatedAt: new Date(),
      })
      .where(
        and(
          eq(agentMemoryIndex.entryId, entryId),
          eq(agentMemoryIndex.userId, this.userId),
        ),
      );
  };

  // 删除索引（通过 entryId）
  deleteByEntryId = async (entryId: string) => {
    return this.db
      .delete(agentMemoryIndex)
      .where(
        and(
          eq(agentMemoryIndex.entryId, entryId),
          eq(agentMemoryIndex.userId, this.userId),
        ),
      );
  };

  // 批量删除
  deleteByEntryIds = async (entryIds: string[]) => {
    return this.db
      .delete(agentMemoryIndex)
      .where(
        and(
          eq(agentMemoryIndex.userId, this.userId),
          inArray(agentMemoryIndex.entryId, entryIds),
        ),
      );
  };

  // 更新访问统计
  recordAccess = async (id: string) => {
    return this.db
      .update(agentMemoryIndex)
      .set({
        accessCount: sql`${agentMemoryIndex.accessCount} + 1`,
        lastAccessedAt: new Date(),
      })
      .where(and(eq(agentMemoryIndex.id, id), eq(agentMemoryIndex.userId, this.userId)));
  };
}
```

## 注册到 Lambda Router

```typescript
// src/server/routers/lambda/index.ts
import { agentMemoryRouter } from './agentMemory';

export const lambdaRouter = router({
  // ... 其他 routers
  agentMemory: agentMemoryRouter,
});
```

## 前端调用示例

### 查询记忆列表

```typescript
const { data: memories } = api.agentMemory.getMemories.useQuery({
  category: 'user',
});
```

### 创建记忆

```typescript
const createMutation = api.agentMemory.createMemory.useMutation();

createMutation.mutate({
  category: 'feedback',
  title: '用户偏好简洁回答',
  content: '用户明确表示不喜欢冗长的解释，希望回答简洁直接。',
  description: '用户喜欢简洁直接的回答风格',
});
```

### 获取记忆索引（供 LLM 使用）

```typescript
const { data: index } = api.agentMemory.getMemoryIndex.useQuery();

// 返回格式：
// [
//   { id: '1', category: 'user', title: '用户偏好', description: '...' },
//   { id: '2', category: 'project', title: '当前项目', description: '...' },
// ]
```

## LLM 工具接口

聊天过程中 LLM 通过工具调用管理记忆：

```typescript
// src/server/routers/lambda/chatAgentMemory.ts
export const chatAgentMemoryRouter = router({
  // LLM 读取记忆详情
  read: authedProcedure
    .input(z.object({ entryId: z.string() }))
    .mutation(async ({ input, ctx }) => {
      const memory = await ctx.agentMemoryModel.findById(input.entryId);
      if (memory) {
        // 更新访问统计
        await ctx.agentMemoryIndexModel.recordAccess(input.entryId);
      }
      return memory;
    }),

  // LLM 创建记忆
  create: authedProcedure
    .input(
      z.object({
        category: z.enum(['user', 'feedback', 'project', 'reference']),
        title: z.string(),
        content: z.string(),
      })
    )
    .mutation(async ({ input, ctx }) => {
      return ctx.agentMemoryModel.create({
        agentId: DEFAULT_AGENT_ID,
        ...input,
      });
    }),

  // LLM 更新记忆
  update: authedProcedure
    .input(
      z.object({
        entryId: z.string(),
        content: z.string(),
      })
    )
    .mutation(async ({ input, ctx }) => {
      return ctx.agentMemoryModel.update(input.entryId, {
        content: input.content,
      });
    }),

  // LLM 删除记忆
  delete: authedProcedure
    .input(z.object({ entryId: z.string() }))
    .mutation(async ({ input, ctx }) => {
      return ctx.agentMemoryModel.delete(input.entryId);
    }),

  // LLM 列出所有记忆
  list: authedProcedure.query(async ({ ctx }) => {
    return ctx.agentMemoryIndexModel.queryByAgentId(DEFAULT_AGENT_ID);
  }),
});
```

## HTTP 请求示例

tRPC 通过 HTTP POST 请求调用，请求体为 JSON 格式。

### 基础请求结构

```http
POST /api/trpc/agentMemory.{procedure} HTTP/1.1
Host: api.example.com
Content-Type: application/json
Authorization: Bearer {access_token}

{
  "json": { /* 输入参数 */ }
}
```

### 1. 查询记忆列表

**请求:**
```http
POST /api/trpc/agentMemory.getMemories HTTP/1.1
Host: api.example.com
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

{
  "json": {
    "category": "user",
    "search": "偏好"
  }
}
```

**返回数据:**
```json
{
  "result": {
    "data": {
      "json": [
        {
          "id": "agent_memory_01HQ1234567890",
          "userId": "user_01HQ1234567890",
          "agentId": "default_agent",
          "category": "user",
          "title": "用户偏好简洁回答",
          "content": "用户明确表示不喜欢冗长的解释，希望回答简洁直接，避免过多的技术细节。",
          "sourceSessionId": "session_01HQ1234567890",
          "sourceMessageIds": ["msg_01HQ1234567890", "msg_01HQ1234567891"],
          "isActive": true,
          "createdAt": "2024-01-15T08:30:00Z",
          "updatedAt": "2024-01-15T08:30:00Z"
        },
        {
          "id": "agent_memory_01HQ1234567891",
          "userId": "user_01HQ1234567890",
          "agentId": "default_agent",
          "category": "user",
          "title": "用户是数据科学家",
          "content": "用户是数据科学家，目前正在调查系统中的日志记录情况，关注可观测性。",
          "sourceSessionId": null,
          "sourceMessageIds": null,
          "isActive": true,
          "createdAt": "2024-01-14T10:20:00Z",
          "updatedAt": "2024-01-14T10:20:00Z"
        }
      ]
    }
  }
}
```

### 2. 获取单个记忆详情

**请求:**
```http
POST /api/trpc/agentMemory.getMemory HTTP/1.1
Host: api.example.com
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

{
  "json": {
    "id": "agent_memory_01HQ1234567890"
  }
}
```

**返回数据:**
```json
{
  "result": {
    "data": {
      "json": {
        "id": "agent_memory_01HQ1234567890",
        "userId": "user_01HQ1234567890",
        "agentId": "default_agent",
        "category": "feedback",
        "title": "避免使用表情符号",
        "content": "用户反馈不喜欢在回答中使用表情符号，认为不够专业。\n\n**Why:** 用户认为表情符号降低了沟通的专业性\n\n**How to apply:** 在所有正式回答中避免使用 emoji 或表情符号",
        "sourceSessionId": "session_01HQ1234567890",
        "sourceMessageIds": ["msg_01HQ1234567892"],
        "isActive": true,
        "createdAt": "2024-01-15T08:30:00Z",
        "updatedAt": "2024-01-16T14:22:00Z"
      }
    }
  }
}
```

### 3. 获取记忆索引（供 LLM 使用）

**请求:**
```http
POST /api/trpc/agentMemory.getMemoryIndex HTTP/1.1
Host: api.example.com
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

{
  "json": null
}
```

**返回数据:**
```json
{
  "result": {
    "data": {
      "json": [
        {
          "id": "agent_mem_idx_01HQ1234567890",
          "userId": "user_01HQ1234567890",
          "agentId": "default_agent",
          "entryId": "agent_memory_01HQ1234567890",
          "category": "user",
          "title": "用户偏好简洁回答",
          "description": "用户明确表示不喜欢冗长的解释，希望回答简洁直接",
          "isActive": true,
          "accessCount": 5,
          "lastAccessedAt": "2024-01-16T10:30:00Z",
          "createdAt": "2024-01-15T08:30:00Z",
          "updatedAt": "2024-01-16T10:30:00Z"
        },
        {
          "id": "agent_mem_idx_01HQ1234567891",
          "userId": "user_01HQ1234567890",
          "agentId": "default_agent",
          "entryId": "agent_memory_01HQ1234567891",
          "category": "feedback",
          "title": "避免使用表情符号",
          "description": "用户反馈不喜欢在回答中使用表情符号",
          "isActive": true,
          "accessCount": 3,
          "lastAccessedAt": "2024-01-15T16:45:00Z",
          "createdAt": "2024-01-14T10:20:00Z",
          "updatedAt": "2024-01-15T16:45:00Z"
        },
        {
          "id": "agent_mem_idx_01HQ1234567892",
          "userId": "user_01HQ1234567890",
          "agentId": "default_agent",
          "entryId": "agent_memory_01HQ1234567892",
          "category": "project",
          "title": "认证模块开发",
          "description": "正在开发用户认证模块，计划3月发布",
          "isActive": true,
          "accessCount": 8,
          "lastAccessedAt": "2024-01-16T09:15:00Z",
          "createdAt": "2024-01-10T14:00:00Z",
          "updatedAt": "2024-01-16T09:15:00Z"
        },
        {
          "id": "agent_mem_idx_01HQ1234567893",
          "userId": "user_01HQ1234567890",
          "agentId": "default_agent",
          "entryId": "agent_memory_01HQ1234567893",
          "category": "reference",
          "title": "Bug 跟踪系统",
          "description": "Bug 跟踪在 Linear 项目 INGEST",
          "isActive": true,
          "accessCount": 2,
          "lastAccessedAt": "2024-01-12T11:20:00Z",
          "createdAt": "2024-01-12T11:20:00Z",
          "updatedAt": "2024-01-12T11:20:00Z"
        }
      ]
    }
  }
}
```

### 4. 创建记忆

**请求:**
```http
POST /api/trpc/agentMemory.createMemory HTTP/1.1
Host: api.example.com
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

{
  "json": {
    "category": "feedback",
    "title": "用户偏好简洁回答",
    "content": "用户明确表示不喜欢冗长的解释，希望回答简洁直接。\n\n**Why:** 用户认为过多的技术细节会分散注意力\n\n**How to apply:** 先给出简洁答案，再根据需要补充细节",
    "description": "用户喜欢简洁直接的回答风格",
    "sourceSessionId": "session_01HQ1234567890",
    "sourceMessageIds": ["msg_01HQ1234567890"]
  }
}
```

**返回数据:**
```json
{
  "result": {
    "data": {
      "json": {
        "id": "agent_memory_01HQ1234567894",
        "userId": "user_01HQ1234567890",
        "agentId": "default_agent",
        "category": "feedback",
        "title": "用户偏好简洁回答",
        "content": "用户明确表示不喜欢冗长的解释，希望回答简洁直接。\n\n**Why:** 用户认为过多的技术细节会分散注意力\n\n**How to apply:** 先给出简洁答案，再根据需要补充细节",
        "sourceSessionId": "session_01HQ1234567890",
        "sourceMessageIds": ["msg_01HQ1234567890"],
        "isActive": true,
        "createdAt": "2024-01-17T09:00:00Z",
        "updatedAt": "2024-01-17T09:00:00Z"
      }
    }
  }
}
```

### 5. 更新记忆

**请求:**
```http
POST /api/trpc/agentMemory.updateMemory HTTP/1.1
Host: api.example.com
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

{
  "json": {
    "id": "agent_memory_01HQ1234567890",
    "value": {
      "content": "用户明确表示不喜欢冗长的解释，希望回答简洁直接。例外情况：技术讨论时可以适当增加细节。\n\n**Why:** 用户认为过多的技术细节会分散注意力\n\n**How to apply:** 先给出简洁答案，再根据需要补充细节",
      "description": "用户喜欢简洁回答，但技术讨论除外"
    }
  }
}
```

**返回数据:**
```json
{
  "result": {
    "data": {
      "json": {
        "id": "agent_memory_01HQ1234567890",
        "userId": "user_01HQ1234567890",
        "agentId": "default_agent",
        "category": "feedback",
        "title": "用户偏好简洁回答",
        "content": "用户明确表示不喜欢冗长的解释，希望回答简洁直接。例外情况：技术讨论时可以适当增加细节。\n\n**Why:** 用户认为过多的技术细节会分散注意力\n\n**How to apply:** 先给出简洁答案，再根据需要补充细节",
        "sourceSessionId": "session_01HQ1234567890",
        "sourceMessageIds": ["msg_01HQ1234567890"],
        "isActive": true,
        "createdAt": "2024-01-15T08:30:00Z",
        "updatedAt": "2024-01-17T10:30:00Z"
      }
    }
  }
}
```

### 6. 删除记忆

**请求:**
```http
POST /api/trpc/agentMemory.deleteMemory HTTP/1.1
Host: api.example.com
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

{
  "json": {
    "id": "agent_memory_01HQ1234567890"
  }
}
```

**返回数据:**
```json
{
  "result": {
    "data": {
      "json": {
        "success": true,
        "deletedId": "agent_memory_01HQ1234567890"
      }
    }
  }
}
```

### 7. 批量删除记忆

**请求:**
```http
POST /api/trpc/agentMemory.batchDeleteMemories HTTP/1.1
Host: api.example.com
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

{
  "json": {
    "ids": [
      "agent_memory_01HQ1234567890",
      "agent_memory_01HQ1234567891",
      "agent_memory_01HQ1234567892"
    ]
  }
}
```

**返回数据:**
```json
{
  "result": {
    "data": {
      "json": {
        "success": true,
        "deletedCount": 3,
        "deletedIds": [
          "agent_memory_01HQ1234567890",
          "agent_memory_01HQ1234567891",
          "agent_memory_01HQ1234567892"
        ]
      }
    }
  }
}
```

### 8. 统计记忆数量

**请求:**
```http
POST /api/trpc/agentMemory.countMemories HTTP/1.1
Host: api.example.com
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

{
  "json": {
    "category": "feedback"
  }
}
```

**返回数据:**
```json
{
  "result": {
    "data": {
      "json": 5
    }
  }
}
```

## LLM 工具 HTTP 请求示例

### LLM 读取记忆详情

**请求:**
```http
POST /api/trpc/chatAgentMemory.read HTTP/1.1
Host: api.example.com
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

{
  "json": {
    "entryId": "agent_memory_01HQ1234567890"
  }
}
```

**返回数据:**
```json
{
  "result": {
    "data": {
      "json": {
        "id": "agent_memory_01HQ1234567890",
        "category": "user",
        "title": "用户偏好简洁回答",
        "content": "用户明确表示不喜欢冗长的解释...",
        "accessCount": 6,
        "lastAccessedAt": "2024-01-17T11:00:00Z"
      }
    }
  }
}
```

### LLM 创建记忆

**请求:**
```http
POST /api/trpc/chatAgentMemory.create HTTP/1.1
Host: api.example.com
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

{
  "json": {
    "category": "project",
    "title": "合并冻结通知",
    "content": "2026-03-05 开始合并冻结，移动端团队正在切发布分支。\n\n**Why:** 移动端需要稳定代码库进行发布准备\n\n**How to apply:** 标记所有非关键 PR，建议冻结后再合并"
  }
}
```

**返回数据:**
```json
{
  "result": {
    "data": {
      "json": {
        "id": "agent_memory_01HQ1234567895",
        "category": "project",
        "title": "合并冻结通知",
        "content": "2026-03-05 开始合并冻结，移动端团队正在切发布分支...",
        "createdAt": "2024-01-17T11:30:00Z"
      }
    }
  }
}
```

### LLM 列出所有记忆

**请求:**
```http
POST /api/trpc/chatAgentMemory.list HTTP/1.1
Host: api.example.com
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

{
  "json": null
}
```

**返回数据:**
```json
{
  "result": {
    "data": {
      "json": [
        { "id": "agent_mem_idx_01HQ1234567890", "category": "user", "title": "用户偏好简洁回答" },
        { "id": "agent_mem_idx_01HQ1234567891", "category": "feedback", "title": "避免使用表情符号" },
        { "id": "agent_mem_idx_01HQ1234567892", "category": "project", "title": "认证模块开发" },
        { "id": "agent_mem_idx_01HQ1234567893", "category": "reference", "title": "Bug 跟踪系统" },
        { "id": "agent_mem_idx_01HQ1234567895", "category": "project", "title": "合并冻结通知" }
      ]
    }
  }
}
```

## 错误响应示例

### 未授权
```http
HTTP/1.1 401 Unauthorized
Content-Type: application/json

{
  "error": {
    "message": "Unauthorized",
    "code": -32001,
    "data": {
      "code": "UNAUTHORIZED",
      "httpStatus": 401,
      "path": "agentMemory.getMemories"
    }
  }
}
```

### 记忆不存在
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "result": {
    "data": {
      "json": null
    }
  }
}
```

### 参数错误
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "error": {
    "message": "Input validation failed",
    "code": -32600,
    "data": {
      "issues": [
        {
          "code": "invalid_enum_value",
          "message": "Invalid enum value. Expected 'user' | 'feedback' | 'project' | 'reference'",
          "path": ["category"]
        }
      ]
    }
  }
}
```

## 类型定义

```typescript
// packages/types/src/agentMemory.ts
export interface AgentMemoryItem {
  id: string;
  userId: string;
  agentId: string;
  category: 'user' | 'feedback' | 'project' | 'reference';
  title: string;
  content: string;
  sourceSessionId?: string;
  sourceMessageIds?: string[];
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface AgentMemoryIndexItem {
  id: string;
  userId: string;
  agentId: string;
  entryId: string;
  category: 'user' | 'feedback' | 'project' | 'reference';
  title: string;
  description: string;
  isActive: boolean;
  accessCount: number;
  lastAccessedAt: Date;
  createdAt: Date;
  updatedAt: Date;
}

export type NewAgentMemory = Omit<
  AgentMemoryItem,
  'id' | 'createdAt' | 'updatedAt' | 'userId'
>;
```
