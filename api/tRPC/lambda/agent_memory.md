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

// 获取记忆索引（列表展示）
const { data: index } = api.agentMemory.getMemoryIndex.useQuery();

// 获取单个记忆详情
const { data: memory } = api.agentMemory.getMemory.useQuery({
  id: 'agent_memory_xxx',
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

### 1. getMemoryIndex - 获取记忆索引

获取轻量级的记忆索引列表，用于列表展示。只包含标题和描述，不包含完整 content。

**输入参数:** 无

**前端调用:**
```typescript
const { data: index, isLoading } = api.agentMemory.getMemoryIndex.useQuery();
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
    "isActive": true,
    "accessCount": 5,
    "lastAccessedAt": "2024-01-16T10:30:00Z",
    "createdAt": "2024-01-15T08:30:00Z",
    "updatedAt": "2024-01-16T10:30:00Z"
  }
]
```

---

### 2. getMemory - 获取记忆详情

根据 ID 获取记忆的完整内容。

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

### 3. createMemory - 创建记忆

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

---

### 4. updateMemory - 更新记忆

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

### 5. deleteMemory - 删除记忆

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
    utils.agentMemory.getMemoryIndex.invalidate();
  },
});

deleteMutation.mutate({ id: 'agent_memory_01HQ1234567890' });
```

**返回数据:**
```typescript
{ success: boolean; deletedId: string }
```

---

### 6. batchDeleteMemories - 批量删除记忆

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

---

### 7. countMemories - 统计记忆数量

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

### 8. getSettings - 获取记忆设置

获取当前用户的记忆系统设置。

**输入参数:** 无

**前端调用:**
```typescript
const { data: settings } = api.agentMemory.getSettings.useQuery();
```

**返回数据:**
```typescript
AgentMemorySettings
```

```json
{
  "enabled": true,
  "maxEntriesPerUser": 200,
  "defaultReadEnabled": true,
  "defaultWriteEnabled": true,
  "categories": ["user", "feedback", "project", "reference", "general"]
}
```

---

### 9. updateSettings - 更新记忆设置

更新记忆系统设置。

**输入参数:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| enabled | `boolean` | 否 | 是否启用记忆系统 |
| maxEntriesPerUser | `number` | 否 | 每用户最大记忆数 |
| defaultReadEnabled | `boolean` | 否 | 默认开启记忆读取 |
| defaultWriteEnabled | `boolean` | 否 | 默认开启记忆写入 |

**前端调用:**
```typescript
const updateSettings = api.agentMemory.updateSettings.useMutation();

updateSettings.mutate({
  enabled: true,
  defaultReadEnabled: true,
  defaultWriteEnabled: false,
});
```

**返回数据:**
```typescript
AgentMemorySettings
```

---

## 类型定义

```typescript
// 记忆索引（列表展示用）
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

// 记忆条目（详情用）
interface AgentMemoryItem {
  id: string;
  category: 'user' | 'feedback' | 'project' | 'reference';
  title: string;
  content: string;  // 完整 Markdown 内容
  description?: string;
  sourceSessionId?: string;
  sourceMessageIds?: string[];
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

// 记忆设置
interface AgentMemorySettings {
  enabled: boolean;
  maxEntriesPerUser: number;
  defaultReadEnabled: boolean;
  defaultWriteEnabled: boolean;
  categories: string[];
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
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState<AgentMemoryIndexItem['category'] | undefined>();
  
  // 获取索引列表（轻量）
  const { data: index, isLoading } = api.agentMemory.getMemoryIndex.useQuery();
  
  // 获取选中记忆的详情
  const { data: selectedMemory } = api.agentMemory.getMemory.useQuery(
    { id: selectedId! },
    { enabled: !!selectedId }
  );
  
  // 删除记忆
  const deleteMutation = api.agentMemory.deleteMemory.useMutation({
    onSuccess: () => {
      setSelectedId(null);
    },
  });
  
  // 筛选逻辑
  const filteredIndex = index?.filter((item) => {
    if (category && item.category !== category) return false;
    if (search && !item.title.includes(search) && !item.description?.includes(search)) return false;
    return true;
  });
  
  if (isLoading) return <div>加载中...</div>;
  
  return (
    <div className="memory-manager">
      {/* 左侧：索引列表 */}
      <div className="index-list">
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
        
        {filteredIndex?.map((item) => (
          <div
            key={item.id}
            className={`index-item ${selectedId === item.entryId ? 'active' : ''}`}
            onClick={() => setSelectedId(item.entryId)}
          >
            <span className="category">{item.category}</span>
            <h4>{item.title}</h4>
            <p>{item.description}</p>
          </div>
        ))}
      </div>
      
      {/* 右侧：详情面板 */}
      <div className="detail-panel">
        {selectedMemory ? (
          <>
            <div className="detail-header">
              <h2>{selectedMemory.title}</h2>
              <button
                onClick={() => deleteMutation.mutate({ id: selectedMemory.id })}
                disabled={deleteMutation.isPending}
              >
                删除
              </button>
            </div>
            <div className="detail-content">
              <pre>{selectedMemory.content}</pre>
            </div>
            <div className="detail-meta">
              <span>更新于: {new Date(selectedMemory.updatedAt).toLocaleString()}</span>
              <span>访问次数: {selectedMemory.accessCount || 0}</span>
            </div>
          </>
        ) : (
          <div className="empty">选择一个记忆查看详情</div>
        )}
      </div>
    </div>
  );
}
```

### 聊天界面记忆开关

```typescript
'use client';

import { api } from '@/services/api';

export function MemoryToggle({ sessionId }: { sessionId: string }) {
  // 获取当前会话配置
  const { data: config } = api.agent.getAgentConfig.useQuery({ sessionId });
  
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
              id: sessionId,
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
              id: sessionId,
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

### 获取记忆索引

```http
POST /api/trpc/agentMemory.getMemoryIndex HTTP/1.1
Host: api.example.com
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

{}
```

**返回:**
```json
{
  "result": {
    "data": {
      "json": [
        {
          "id": "agent_mem_idx_01HQ1234567890",
          "entryId": "agent_memory_01HQ1234567890",
          "category": "user",
          "title": "用户偏好简洁回答",
          "description": "用户明确表示不喜欢冗长的解释",
          "isActive": true,
          "accessCount": 5,
          "lastAccessedAt": "2024-01-16T10:30:00Z",
          "createdAt": "2024-01-15T08:30:00Z",
          "updatedAt": "2024-01-16T10:30:00Z"
        }
      ]
    }
  }
}
```

### 获取记忆详情

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

**返回:**
```json
{
  "result": {
    "data": {
      "json": {
        "id": "agent_memory_01HQ1234567890",
        "category": "feedback",
        "title": "用户偏好简洁回答",
        "content": "用户明确表示不喜欢冗长的解释...",
        "isActive": true,
        "createdAt": "2024-01-15T08:30:00Z",
        "updatedAt": "2024-01-15T08:30:00Z"
      }
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
