# Session 会话管理接口

会话（Session）是用户与 AI 对话的容器，每个会话包含多个消息和配置。

## 接口列表

### getGroupedSessions

获取分组的会话列表（包含普通会话和群组会话）。

**类型**: `query`

**权限**: 公开（publicProcedure，但需要 userId）

**输入参数**: 无

**返回数据**:

```typescript
{
  sessions: Array<{
    id: string;
    title: string;
    description?: string;
    avatar?: string;
    backgroundColor?: string;
    type: 'agent' | 'group';
    group?: string;  // 所属分组 ID
    pinned?: boolean;
    createdAt: string;
    updatedAt: string;
    // ... 其他字段
  }>;
  sessionGroups: Array<{
    id: string;
    name: string;
    sort?: number;
    createdAt: string;
    updatedAt: string;
  }>;
}
```

**说明**:

- 返回所有会话（agent 会话和 group 会话）
- 按 `updatedAt` 降序排序
- 包含会话分组信息

---

### getSessions

分页获取会话列表。

**类型**: `query`

**权限**: 需要认证

**输入参数**:

```typescript
{
  current?: number;   // 当前页码（从 1 开始）
  pageSize?: number;  // 每页数量
}
```

**返回数据**:

```typescript
Array<{
  id: string;
  title: string;
  type: 'agent' | 'group';
  group?: string;
  pinned?: boolean;
  createdAt: string;
  updatedAt: string;
  // ... 其他字段
}>
```

---

### createSession

创建新会话。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  type: 'agent' | 'group';
  session: {
    id?: string;
    title?: string;
    description?: string;
    avatar?: string;
    backgroundColor?: string;
    group?: string;      // 所属分组 ID
    pinned?: boolean;
    slug?: string;
    // ... 其他字段
  };
  config: {
    // Agent 配置（部分字段）
    systemRole?: string;
    model?: string;
    provider?: string;
    temperature?: number;
    topP?: number;
    maxTokens?: number;
    // ... 其他配置
  };
}
```

**返回数据**:

```typescript
string // 新创建的会话 ID
```

---

### updateSession

更新会话信息。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
  value: {
    title?: string;
    description?: string;
    avatar?: string;
    backgroundColor?: string;
    group?: string;
    pinned?: boolean;
    slug?: string;
    // ... 其他字段
  };
}
```

**返回数据**:

```typescript
void
```

---

### updateSessionConfig

更新会话配置（Agent 配置）。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
  value: {
    // 任意配置字段
    [key: string]: any;
  };
}
```

**返回数据**:

```typescript
void
```

---

### updateSessionChatConfig

更新会话的聊天配置。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
  value: {
    // AgentChatConfig 部分字段
    autoCreateTopicThreshold?: number;
    displayMode?: 'chat' | 'document';
    enableAutoCreateTopic?: boolean;
    enableCompressThreshold?: boolean;
    enableHistoryCount?: boolean;
    historyCount?: number;
    // ... 其他配置
  };
}
```

**返回数据**:

```typescript
void
```

---

### removeSession

删除指定会话。

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

### removeAllSessions

删除所有会话。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**: 无

**返回数据**:

```typescript
void
```

---

### cloneSession

克隆（复制）会话。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
  newTitle: string;
}
```

**返回数据**:

```typescript
string // 新会话 ID
```

**说明**:

- 会复制会话的所有配置和消息
- 使用新的标题

---

### searchSessions

按关键词搜索会话。

**类型**: `query`

**权限**: 需要认证

**输入参数**:

```typescript
{
  keywords: string;
}
```

**返回数据**:

```typescript
Array<{
  id: string;
  title: string;
  // ... 其他字段
}>
```

---

### rankSessions

获取会话排行（按消息数）。

**类型**: `query`

**权限**: 需要认证

**输入参数**:

```typescript
number | undefined  // 返回数量限制（可选）
```

**返回数据**:

```typescript
Array<{
  sessionId: string;
  messageCount: number;
}>
```

---

### countSessions

统计会话数量。

**类型**: `query`

**权限**: 需要认证

**输入参数**:

```typescript
{
  startDate?: string;   // 开始日期（ISO 格式）
  endDate?: string;     // 结束日期（ISO 格式）
  range?: [string, string];  // 日期范围
} | undefined
```

**返回数据**:

```typescript
number
```

---

### batchCreateSessions

批量创建会话。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
Array<{
  id: string;
  type: string;
  meta: {
    title: string;
    description?: string;
    avatar?: string;
    // ... 其他元数据
  };
  config: object;
  group?: string;
  pinned?: boolean;
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

### 获取所有会话

```typescript
const { sessions, sessionGroups } = await trpc.session.getGroupedSessions.query();

console.log(`共 ${sessions.length} 个会话`);
console.log(`共 ${sessionGroups.length} 个分组`);
```

### 创建新会话

```typescript
const sessionId = await trpc.session.createSession.mutate({
  type: 'agent',
  session: {
    title: '我的 AI 助手',
    description: '一个有用的助手',
    avatar: '🤖'
  },
  config: {
    systemRole: '你是一个有用的助手',
    model: 'gpt-4',
    provider: 'openai',
    temperature: 0.7
  }
});

console.log(`创建的会话 ID: ${sessionId}`);
```

### 更新会话标题

```typescript
await trpc.session.updateSession.mutate({
  id: 'session-id',
  value: {
    title: '新标题',
    pinned: true
  }
});
```

### 搜索会话

```typescript
const results = await trpc.session.searchSessions.query({
  keywords: 'GPT'
});

console.log(`找到 ${results.length} 个会话`);
```

### 克隆会话

```typescript
const newSessionId = await trpc.session.cloneSession.mutate({
  id: 'original-session-id',
  newTitle: '克隆的会话'
});
```

---

## 数据类型

### Session

```typescript
{
  id: string;
  title: string;
  description?: string;
  avatar?: string;
  backgroundColor?: string;
  type: 'agent' | 'group';
  group?: string;
  pinned?: boolean;
  slug?: string;
  createdAt: string;
  updatedAt: string;
}
```

### AgentConfig

```typescript
{
  systemRole?: string;
  model?: string;
  provider?: string;
  temperature?: number;
  topP?: number;
  maxTokens?: number;
  plugins?: string[];
  // ... 更多配置字段
}
```

### AgentChatConfig

```typescript
{
  autoCreateTopicThreshold?: number;
  displayMode?: 'chat' | 'document';
  enableAutoCreateTopic?: boolean;
  enableCompressThreshold?: boolean;
  enableHistoryCount?: boolean;
  historyCount?: number;
  // ... 更多配置字段
}
```
