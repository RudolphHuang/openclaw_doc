# Agent Memory tRPC 接口文档

前端调用 Agent Memory 系统的 tRPC 接口文档。

## 概述

- **路由名称**: `agentMemory`
- **基础路径**: `/api/trpc/agentMemory.{procedure}`
- **认证**: 需要 Bearer Token

## 记忆类型

| 类型 | 说明 | 示例 |
|------|------|------|
| `user` | 用户画像/偏好 | 用户是数据科学家，关注可观测性 |
| `feedback` | 行为指导/反馈 | 用户不喜欢使用表情符号 |
| `project` | 进行中的工作上下文 | 正在开发认证模块，3月发布 |
| `reference` | 外部资源指针 | Bug 跟踪在 Linear 项目 INGEST |

## 前端调用方式

```typescript
import { api } from '@/services/api';

// 查询记忆列表
const { data: memories } = api.agentMemory.getMemories.useQuery({
  category: 'user',
});

// 创建记忆
const createMutation = api.agentMemory.createMemory.useMutation();
createMutation.mutate({
  category: 'feedback',
  title: '用户偏好简洁回答',
  content: '用户明确表示不喜欢冗长的解释...',
});
```

## 接口列表

### 1. getMemories - 查询记忆列表

获取当前用户的记忆列表，支持分类筛选和搜索。

**输入参数:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| category | `'user' \| 'feedback' \| 'project' \| 'reference'` | 否 | 按分类筛选 |
| search | `string` | 否 | 按标题搜索关键词 |
| isActive | `boolean` | 否 | 按激活状态筛选 |

**前端调用:**
```typescript
const { data: memories, isLoading } = api.agentMemory.getMemories.useQuery({
  category: 'feedback',
  search: '偏好',
});
```

**返回数据:**
```typescript
AgentMemoryItem[]
```

```json
[
  {
    "id": "agent_memory_01HQ1234567890",
    "category": "feedback",
    "title": "用户偏好简洁回答",
    "content": "用户明确表示不喜欢冗长的解释...",
    "description": "用户喜欢简洁直接的回答风格",
    "isActive": true,
    "createdAt": "2024-01-15T08:30:00Z",
    "updatedAt": "2024-01-15T08:30:00Z"
  }
]
```

---

### 2. getMemory - 获取单个记忆

根据 ID 获取记忆详情。

**输入参数:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | `string` | 是 | 记忆 ID |

**前端调用:**
```typescript
const { data: memory } = api.agentMemory.getMemory.useQuery({
  id: 'agent_memory_01HQ1234567890',
});
```

**返回数据:**
```typescript
AgentMemoryItem | null
```

```json
{
  "id": "agent_memory_01HQ1234567890",
  "category": "feedback",
  "title": "避免使用表情符号",
  "content": "用户反馈不喜欢在回答中使用表情符号...\n\n**Why:** 用户认为表情符号不够专业\n\n**How to apply:** 在所有正式回答中避免使用 emoji",
  "isActive": true,
  "createdAt": "2024-01-15T08:30:00Z",
  "updatedAt": "2024-01-16T14:22:00Z"
}
```

---

### 3. getMemoryIndex - 获取记忆索引

获取记忆索引列表（供 LLM 使用），只包含标题和描述，不包含完整内容。

**输入参数:** 无

**前端调用:**
```typescript
const { data: index } = api.agentMemory.getMemoryIndex.useQuery();
```

**返回数据:**
```typescript
AgentMemoryIndexItem[]
```

```json
[
  {
    "id": "agent_mem_idx_01HQ1234567890",
    "entryId": "agent_memory_01HQ1234567890",
    "category": "user",
    "title": "用户偏好简洁回答",
    "description": "用户明确表示不喜欢冗长的解释",
    "accessCount": 5,
    "lastAccessedAt": "2024-01-16T10:30:00Z"
  },
  {
    "id": "agent_mem_idx_01HQ1234567891",
    "entryId": "agent_memory_01HQ1234567891",
    "category": "feedback",
    "title": "避免使用表情符号",
    "description": "用户反馈不喜欢在回答中使用表情符号",
    "accessCount": 3,
    "lastAccessedAt": "2024-01-15T16:45:00Z"
  }
]
```

---

### 4. createMemory - 创建记忆

创建新的记忆条目。

**输入参数:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| category | `'user' \| 'feedback' \| 'project' \| 'reference'` | 是 | 记忆分类 |
| title | `string` | 是 | 记忆标题（1-255字符） |
| content | `string` | 是 | 记忆内容（Markdown格式） |
| description | `string` | 否 | 简短描述（最多500字符） |
| sourceSessionId | `string` | 否 | 来源会话ID |
| sourceMessageIds | `string[]` | 否 | 来源消息ID列表 |

**前端调用:**
```typescript
const createMutation = api.agentMemory.createMemory.useMutation({
  onSuccess: (data) => {
    console.log('创建成功:', data.id);
  },
});

createMutation.mutate({
  category: 'feedback',
  title: '用户偏好简洁回答',
  content: `用户明确表示不喜欢冗长的解释，希望回答简洁直接。

**Why:** 用户认为过多的技术细节会分散注意力

**How to apply:** 先给出简洁答案，再根据需要补充细节`,
  description: '用户喜欢简洁直接的回答风格',
});
```

**返回数据:**
```typescript
AgentMemoryItem
```

```json
{
  "id": "agent_memory_01HQ1234567894",
  "category": "feedback",
  "title": "用户偏好简洁回答",
  "content": "用户明确表示不喜欢冗长的解释...",
  "isActive": true,
  "createdAt": "2024-01-17T09:00:00Z",
  "updatedAt": "2024-01-17T09:00:00Z"
}
```

---

### 5. updateMemory - 更新记忆

更新已有的记忆条目。

**输入参数:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | `string` | 是 | 记忆ID |
| value.category | `'user' \| 'feedback' \| 'project' \| 'reference'` | 否 | 记忆分类 |
| value.title | `string` | 否 | 记忆标题 |
| value.content | `string` | 否 | 记忆内容 |
| value.description | `string` | 否 | 简短描述 |
| value.isActive | `boolean` | 否 | 是否激活 |

**前端调用:**
```typescript
const updateMutation = api.agentMemory.updateMemory.useMutation();

updateMutation.mutate({
  id: 'agent_memory_01HQ1234567890',
  value: {
    content: '更新后的内容...',
    description: '更新后的描述',
  },
});
```

**返回数据:**
```typescript
AgentMemoryItem
```

---

### 6. deleteMemory - 删除记忆

删除单个记忆条目。

**输入参数:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | `string` | 是 | 记忆ID |

**前端调用:**
```typescript
const deleteMutation = api.agentMemory.deleteMemory.useMutation({
  onSuccess: () => {
    // 删除成功后刷新列表
    utils.agentMemory.getMemories.invalidate();
  },
});

deleteMutation.mutate({ id: 'agent_memory_01HQ1234567890' });
```

**返回数据:**
```typescript
{ success: boolean; deletedId: string }
```

```json
{
  "success": true,
  "deletedId": "agent_memory_01HQ1234567890"
}
```

---

### 7. batchDeleteMemories - 批量删除记忆

批量删除多个记忆条目。

**输入参数:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| ids | `string[]` | 是 | 记忆ID数组 |

**前端调用:**
```typescript
const batchDeleteMutation = api.agentMemory.batchDeleteMemories.useMutation();

batchDeleteMutation.mutate({
  ids: [
    'agent_memory_01HQ1234567890',
    'agent_memory_01HQ1234567891',
  ],
});
```

**返回数据:**
```typescript
{ success: boolean; deletedCount: number; deletedIds: string[] }
```

```json
{
  "success": true,
  "deletedCount": 2,
  "deletedIds": [
    "agent_memory_01HQ1234567890",
    "agent_memory_01HQ1234567891"
  ]
}
```

---

### 8. countMemories - 统计记忆数量

统计当前用户的记忆数量，可按分类筛选。

**输入参数:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| category | `'user' \| 'feedback' \| 'project' \| 'reference'` | 否 | 按分类统计 |

**前端调用:**
```typescript
const { data: count } = api.agentMemory.countMemories.useQuery({
  category: 'feedback',
});
// 返回: 5
```

**返回数据:**
```typescript
number
```

---

## 类型定义

```typescript
// 记忆条目
interface AgentMemoryItem {
  id: string;
  category: 'user' | 'feedback' | 'project' | 'reference';
  title: string;
  content: string;
  description?: string;
  sourceSessionId?: string;
  sourceMessageIds?: string[];
  isActive: boolean;
  createdAt: string; // ISO 8601 格式
  updatedAt: string; // ISO 8601 格式
}

// 记忆索引（供 LLM 使用）
interface AgentMemoryIndexItem {
  id: string;
  entryId: string;  // 关联的记忆条目ID
  category: 'user' | 'feedback' | 'project' | 'reference';
  title: string;
  description: string;
  isActive: boolean;
  accessCount: number;
  lastAccessedAt: string;
  createdAt: string;
  updatedAt: string;
}
```

---

## 完整使用示例

### 记忆管理页面

```typescript
'use client';

import { api } from '@/services/api';
import { useState } from 'react';

export function MemoryManager() {
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState<'user' | 'feedback' | 'project' | 'reference' | undefined>();
  
  // 查询记忆列表
  const { data: memories, isLoading } = api.agentMemory.getMemories.useQuery({
    search: search || undefined,
    category,
  });
  
  // 删除记忆
  const deleteMutation = api.agentMemory.deleteMemory.useMutation({
    onSuccess: () => {
      // 自动刷新列表
    },
  });
  
  // 创建记忆
  const createMutation = api.agentMemory.createMemory.useMutation();
  
  const handleCreate = async (values: {
    category: 'user' | 'feedback' | 'project' | 'reference';
    title: string;
    content: string;
  }) => {
    await createMutation.mutateAsync({
      ...values,
      description: values.content.slice(0, 100),
    });
  };
  
  if (isLoading) return <div>加载中...</div>;
  
  return (
    <div>
      {/* 筛选和搜索 */}
      <div className="filters">
        <select value={category} onChange={(e) => setCategory(e.target.value as any)}>
          <option value="">全部分类</option>
          <option value="user">用户画像</option>
          <option value="feedback">行为反馈</option>
          <option value="project">项目上下文</option>
          <option value="reference">外部引用</option>
        </select>
        <input
          type="text"
          placeholder="搜索记忆..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />
      </div>
      
      {/* 记忆列表 */}
      <div className="memory-list">
        {memories?.map((memory) => (
          <div key={memory.id} className="memory-card">
            <div className="memory-header">
              <span className="category">{memory.category}</span>
              <h3>{memory.title}</h3>
              <button
                onClick={() => deleteMutation.mutate({ id: memory.id })}
                disabled={deleteMutation.isPending}
              >
                删除
              </button>
            </div>
            <p className="description">{memory.description}</p>
            <div className="memory-content">
              {memory.content}
            </div>
            <div className="memory-meta">
              <span>更新于: {new Date(memory.updatedAt).toLocaleString()}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
```

### 聊天界面记忆开关

```typescript
'use client';

import { api } from '@/services/api';

export function MemoryToggle() {
  // 获取当前会话配置
  const { data: config } = api.agent.getAgentConfig.useQuery({
    sessionId: 'current_session_id',
  });
  
  // 更新会话配置
  const updateConfig = api.session.updateSessionChatConfig.useMutation();
  
  const memoryReadEnabled = config?.chatConfig?.memoryReadEnabled ?? true;
  const memoryWriteEnabled = config?.chatConfig?.memoryWriteEnabled ?? true;
  
  return (
    <div className="memory-toggles">
      <label>
        <input
          type="checkbox"
          checked={memoryReadEnabled}
          onChange={(e) => {
            updateConfig.mutate({
              id: 'session_id',
              value: { memoryReadEnabled: e.target.checked },
            });
          }}
        />
        读取记忆
      </label>
      <label>
        <input
          type="checkbox"
          checked={memoryWriteEnabled}
          onChange={(e) => {
            updateConfig.mutate({
              id: 'session_id',
              value: { memoryWriteEnabled: e.target.checked },
            });
          }}
        />
        写入记忆
      </label>
    </div>
  );
}
```

---

## HTTP 请求示例

### 查询记忆列表

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

**返回:**
```json
{
  "result": {
    "data": {
      "json": [
        {
          "id": "agent_memory_01HQ1234567890",
          "category": "user",
          "title": "用户偏好简洁回答",
          "content": "用户明确表示不喜欢冗长的解释...",
          "isActive": true,
          "createdAt": "2024-01-15T08:30:00Z",
          "updatedAt": "2024-01-15T08:30:00Z"
        }
      ]
    }
  }
}
```

### 创建记忆

```http
POST /api/trpc/agentMemory.createMemory HTTP/1.1
Host: api.example.com
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

{
  "json": {
    "category": "feedback",
    "title": "用户偏好简洁回答",
    "content": "用户明确表示不喜欢冗长的解释...",
    "description": "用户喜欢简洁直接的回答风格"
  }
}
```

**返回:**
```json
{
  "result": {
    "data": {
      "json": {
        "id": "agent_memory_01HQ1234567894",
        "category": "feedback",
        "title": "用户偏好简洁回答",
        "content": "用户明确表示不喜欢冗长的解释...",
        "isActive": true,
        "createdAt": "2024-01-17T09:00:00Z",
        "updatedAt": "2024-01-17T09:00:00Z"
      }
    }
  }
}
```
