# Topic 主题管理接口

Topic（主题）是会话中的子分组，用于组织相关消息。一个会话可以包含多个主题。

## 接口列表

### getTopics

获取主题列表。

**类型**: `query`

**权限**: 公开（publicProcedure，但需要 userId）

**输入参数**:

```typescript
{
  containerId?: string | null;  // 容器 ID（sessionId 或 groupId）
  current?: number;              // 当前页码
  pageSize?: number;             // 每页数量
}
```

**返回数据**:

```typescript
Array<{
  id: string;
  title: string;
  favorite?: boolean;
  sessionId?: string | null;
  groupId?: string | null;
  messages?: string[];  // 消息 ID 列表
  metadata?: {
    model?: string;
    provider?: string;
  };
  historySummary?: string;
  createdAt: string;
  updatedAt: string;
}>
```

---

### getAllTopics

获取所有主题（不分页）。

**类型**: `query`

**权限**: 需要认证

**输入参数**: 无

**返回数据**:

```typescript
Array<Topic>
```

---

### createTopic

创建新主题。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  title: string;
  sessionId?: string | null;  // 所属会话 ID
  groupId?: string | null;    // 所属群组 ID
  messages?: string[];        // 初始消息 ID 列表
  favorite?: boolean;
}
```

**返回数据**:

```typescript
string // 新主题 ID
```

---

### updateTopic

更新主题信息。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
  value: {
    title?: string;
    favorite?: boolean;
    sessionId?: string;
    messages?: string[];
    historySummary?: string;  // 历史摘要
    metadata?: {
      model?: string;
      provider?: string;
    };
  };
}
```

**返回数据**:

```typescript
void
```

---

### removeTopic

删除指定主题。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
}
```

**返回数据**:

```typescript
void
```

---

### removeAllTopics

删除所有主题。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**: 无

**返回数据**:

```typescript
void
```

---

### batchDelete

批量删除主题。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  ids: string[];
}
```

**返回数据**:

```typescript
void
```

---

### batchDeleteBySessionId

删除指定会话的所有主题。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id?: string | null;  // 会话 ID
}
```

**返回数据**:

```typescript
void
```

---

### cloneTopic

克隆主题。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
  newTitle?: string;  // 新标题（可选，默认使用原标题）
}
```

**返回数据**:

```typescript
string // 新主题 ID
```

**说明**:

- 会复制主题和关联的所有消息

---

### searchTopics

按关键词搜索主题。

**类型**: `query`

**权限**: 需要认证

**输入参数**:

```typescript
{
  keywords: string;
  sessionId?: string | null;  // 限定会话（可选）
}
```

**返回数据**:

```typescript
Array<Topic>
```

---

### rankTopics

获取主题排行（按消息数）。

**类型**: `query`

**权限**: 需要认证

**输入参数**:

```typescript
number | undefined  // 返回数量限制（可选）
```

**返回数据**:

```typescript
Array<{
  topicId: string;
  messageCount: number;
}>
```

---

### countTopics

统计主题数量。

**类型**: `query`

**权限**: 需要认证

**输入参数**:

```typescript
{
  startDate?: string;
  endDate?: string;
  range?: [string, string];
} | undefined
```

**返回数据**:

```typescript
number
```

---

### hasTopics

检查是否存在主题。

**类型**: `query`

**权限**: 需要认证

**输入参数**: 无

**返回数据**:

```typescript
boolean // true 表示没有主题，false 表示有主题
```

**说明**: 返回值与常规逻辑相反，需要注意。

---

### batchCreateTopics

批量创建主题。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
Array<{
  id?: string;
  title: string;
  sessionId?: string;
  messages?: string[];
  favorite?: boolean;
}>
```

**返回数据**:

```typescript
{
  success: boolean;
  added: number;
  ids: string[];
  skips: string[];
}
```

---

## 使用示例

### 获取会话的主题列表

```typescript
const topics = await trpc.topic.getTopics.query({
  containerId: 'session-id',
  current: 1,
  pageSize: 20
});

console.log(`共 ${topics.length} 个主题`);
```

### 创建新主题

```typescript
const topicId = await trpc.topic.createTopic.mutate({
  title: '讨论 AI 技术',
  sessionId: 'session-id',
  messages: ['msg-1', 'msg-2']
});
```

### 更新主题

```typescript
await trpc.topic.updateTopic.mutate({
  id: 'topic-id',
  value: {
    title: '新标题',
    favorite: true,
    historySummary: '讨论了 AI 的发展历史和未来趋势'
  }
});
```

### 克隆主题

```typescript
const newTopicId = await trpc.topic.cloneTopic.mutate({
  id: 'topic-id',
  newTitle: '克隆的主题'
});
```

### 搜索主题

```typescript
// 全局搜索
const allResults = await trpc.topic.searchTopics.query({
  keywords: 'AI'
});

// 在特定会话中搜索
const sessionResults = await trpc.topic.searchTopics.query({
  keywords: 'AI',
  sessionId: 'session-id'
});
```

### 批量删除主题

```typescript
await trpc.topic.batchDelete.mutate({
  ids: ['topic-1', 'topic-2', 'topic-3']
});
```

### 删除会话的所有主题

```typescript
await trpc.topic.batchDeleteBySessionId.mutate({
  id: 'session-id'
});
```

### 获取统计信息

```typescript
// 主题数量
const count = await trpc.topic.countTopics.query();

// 主题排行
const rank = await trpc.topic.rankTopics.query(10);

// 检查是否有主题
const isEmpty = await trpc.topic.hasTopics.query();
if (isEmpty) {
  console.log('没有主题');
}
```

---

## 数据类型

### Topic

```typescript
{
  id: string;
  title: string;
  favorite?: boolean;
  sessionId?: string | null;
  groupId?: string | null;
  messages?: string[];
  metadata?: {
    model?: string;
    provider?: string;
  };
  historySummary?: string;
  createdAt: string;
  updatedAt: string;
}
```

---

## 使用场景

### 1. 自动创建主题

当对话达到一定长度时，可以自动创建主题：

```typescript
// 检查消息数量
const messages = await trpc.message.getMessages.query({ sessionId });

if (messages.length >= 10) {
  // 创建新主题
  await trpc.topic.createTopic.mutate({
    title: '自动生成的主题',
    sessionId: sessionId,
    messages: messages.map(m => m.id)
  });
}
```

### 2. 主题收藏

标记重要主题：

```typescript
await trpc.topic.updateTopic.mutate({
  id: 'topic-id',
  value: { favorite: true }
});
```

### 3. 生成主题摘要

为主题添加历史摘要：

```typescript
// 假设通过 AI 生成了摘要
const summary = await generateSummary(messages);

await trpc.topic.updateTopic.mutate({
  id: 'topic-id',
  value: { historySummary: summary }
});
```
