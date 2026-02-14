# Message 消息管理接口

消息是会话中的基本单元，包含用户输入、AI 回复、工具调用等。

## 接口列表

### getMessages

获取消息列表（支持分页和过滤）。

**类型**: `query`

**权限**: 公开（publicProcedure，但需要 userId）

**输入参数**:

```typescript
{
  sessionId?: string | null;  // 会话 ID
  topicId?: string | null;    // 主题 ID
  groupId?: string | null;    // 群组 ID
  current?: number;            // 当前页码
  pageSize?: number;           // 每页数量
}
```

**返回数据**:

```typescript
Array<{
  id: string;
  role: 'user' | 'assistant' | 'system' | 'tool';
  content: string;
  createdAt: string;
  updatedAt: string;
  parentId?: string | null;
  topicId?: string | null;
  sessionId?: string | null;
  groupId?: string | null;
  model?: string;
  provider?: string;
  tools?: object;
  plugin?: object;
  pluginError?: object | null;
  pluginState?: object;
  translate?: {
    content: string;
    from: string;
    to: string;
  } | false;
  tts?: {
    contentMd5: string;
    file: string;
    voice: string;
  } | false;
  metadata?: object;
  // ... 其他字段
}>
```

---

### getAllMessagesInSession

获取指定会话的所有消息（不分页）。

**类型**: `query`

**权限**: 需要认证

**输入参数**:

```typescript
{
  sessionId?: string | null;
}
```

**返回数据**:

```typescript
Array<UIChatMessage>
```

**说明**: 此接口将在 V2 版本中移除，建议使用 `getMessages`。

---

### getAllMessages

获取用户的所有消息（不分页）。

**类型**: `query`

**权限**: 需要认证

**输入参数**: 无

**返回数据**:

```typescript
Array<UIChatMessage>
```

**说明**: 此接口将在 V2 版本中移除，建议使用 `getMessages`。

---

### createMessage

创建新消息。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  role: 'user' | 'assistant' | 'system' | 'tool';
  content: string;
  sessionId?: string | null;
  topicId?: string | null;
  groupId?: string | null;
  parentId?: string | null;
  model?: string;
  provider?: string;
  tools?: object;
  plugin?: object;
  metadata?: object;
  // ... 其他字段
}
```

**返回数据**:

```typescript
string // 新消息 ID
```

**说明**:

- 会自动设置 `sourceType`：
  - 使用系统 API Key 时为 `'api'`
  - 浏览器访问时为 `'web'`

---

### update

更新消息内容或状态。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
  value: {
    content?: string;
    role?: string;
    model?: string;
    provider?: string;
    tools?: object;
    metadata?: object;
    // ... 其他字段
  };
}
```

**返回数据**:

```typescript
void
```

**说明**:

- 如果用户提供了自己的 API Key，将跳过积分扣除检查

---

### updateMetadata

更新消息的元数据。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
  value: {
    costPoints?: number;  // 消耗的积分
    usage?: object;       // 使用统计
    [key: string]: any;   // 其他元数据
  };
}
```

**返回数据**:

```typescript
void
```

**说明**:

- 会检查 `costPoints` 是否已存在，避免重复扣除积分
- 如果 `costPoints` 已存在或显式提供，将跳过积分扣除

---

### getMessageMetadata

获取消息的元数据。

**类型**: `query`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
}
```

**返回数据**:

```typescript
object // 元数据对象
```

**错误**:

- `NOT_FOUND`: 消息不存在

---

### removeMessage

删除单条消息。

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

### removeMessages

批量删除消息。

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

### removeMessagesByAssistant

删除指定会话/主题/群组的所有助手消息。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  sessionId?: string | null;
  topicId?: string | null;
  groupId?: string | null;
}
```

**返回数据**:

```typescript
void
```

---

### removeMessagesByGroup

删除指定群组的所有消息。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  groupId: string;
  topicId?: string | null;
}
```

**返回数据**:

```typescript
void
```

---

### removeAllMessages

删除用户的所有消息。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**: 无

**返回数据**:

```typescript
void
```

---

### removeMessageQuery

删除消息的查询记录（RAG 相关）。

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

## 翻译相关

### updateTranslate

更新或删除消息翻译。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
  value: {
    content: string;
    from: string;
    to: string;
  } | false;  // false 表示删除翻译
}
```

**返回数据**:

```typescript
void
```

---

## TTS 相关

### updateTTS

更新或删除消息的 TTS 音频。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
  value: {
    contentMd5?: string;
    file?: string;
    voice?: string;
  } | false;  // false 表示删除 TTS
}
```

**返回数据**:

```typescript
void
```

---

## 插件相关

### updateMessagePlugin

更新消息的插件状态。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
  value: {
    error?: object | null;
    state?: object;
    // ... 其他插件字段
  };
}
```

**返回数据**:

```typescript
void
```

---

### updatePluginState

更新插件状态。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
  value: object;  // 插件状态对象
}
```

**返回数据**:

```typescript
void
```

---

### updatePluginError

更新插件错误信息。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
  value: object | null;  // 错误对象或 null
}
```

**返回数据**:

```typescript
void
```

---

## RAG 相关

### updateMessageRAG

更新消息的 RAG（检索增强生成）参数。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
  value: {
    // RAG 参数
    [key: string]: any;
  };
}
```

**返回数据**:

```typescript
void
```

---

## 统计相关

### count

统计消息数量。

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

### countWords

统计消息字数。

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

### getHeatmaps

获取消息热力图数据（按日期统计）。

**类型**: `query`

**权限**: 需要认证

**输入参数**: 无

**返回数据**:

```typescript
Array<{
  date: string;
  count: number;
}>
```

---

### rankModels

获取模型使用排行。

**类型**: `query`

**权限**: 需要认证

**输入参数**: 无

**返回数据**:

```typescript
Array<{
  model: string;
  count: number;
}>
```

---

### searchMessages

按关键词搜索消息。

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
Array<Message>
```

---

### batchCreateMessages

批量创建消息。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
Array<any>  // 消息对象数组
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

### 获取会话消息

```typescript
const messages = await trpc.message.getMessages.query({
  sessionId: 'session-id',
  current: 1,
  pageSize: 50
});

console.log(`共 ${messages.length} 条消息`);
```

### 创建用户消息

```typescript
const messageId = await trpc.message.createMessage.mutate({
  role: 'user',
  content: '你好，请介绍一下你自己',
  sessionId: 'session-id'
});
```

### 更新消息内容

```typescript
await trpc.message.update.mutate({
  id: 'message-id',
  value: {
    content: '修改后的内容'
  }
});
```

### 添加消息翻译

```typescript
await trpc.message.updateTranslate.mutate({
  id: 'message-id',
  value: {
    content: 'Hello, please introduce yourself',
    from: 'zh-CN',
    to: 'en-US'
  }
});
```

### 删除消息翻译

```typescript
await trpc.message.updateTranslate.mutate({
  id: 'message-id',
  value: false
});
```

### 搜索消息

```typescript
const results = await trpc.message.searchMessages.query({
  keywords: 'GPT'
});
```

### 获取统计数据

```typescript
// 消息数量
const count = await trpc.message.count.query();

// 字数统计
const words = await trpc.message.countWords.query({
  startDate: '2024-01-01',
  endDate: '2024-12-31'
});

// 热力图
const heatmap = await trpc.message.getHeatmaps.query();

// 模型排行
const modelRank = await trpc.message.rankModels.query();
```

---

## 数据类型

### Message

```typescript
{
  id: string;
  role: 'user' | 'assistant' | 'system' | 'tool';
  content: string;
  sessionId?: string | null;
  topicId?: string | null;
  groupId?: string | null;
  parentId?: string | null;
  model?: string;
  provider?: string;
  tools?: object;
  plugin?: object;
  pluginError?: object | null;
  pluginState?: object;
  translate?: {
    content: string;
    from: string;
    to: string;
  } | false;
  tts?: {
    contentMd5: string;
    file: string;
    voice: string;
  } | false;
  metadata?: object;
  createdAt: string;
  updatedAt: string;
}
```

### Metadata

```typescript
{
  costPoints?: number;    // 消耗积分
  usage?: {
    promptTokens?: number;
    completionTokens?: number;
    totalTokens?: number;
  };
  [key: string]: any;
}
```
