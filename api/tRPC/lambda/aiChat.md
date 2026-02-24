# AI Chat AI 聊天接口

在服务端发送 AI 聊天消息，创建新的对话主题并获取 AI 回复。同时支持结构化 JSON 输出。

## 主要接口

### sendMessageInServer

在服务端发送消息并获取 AI 回复（创建新主题）。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  sessionId?: string;           // 会话 ID（可选）
  threadId?: string;            // 线程 ID（可选）
  topicId?: string;             // 主题 ID（可选，如果提供则不在 newTopic 中创建）
  newUserMessage: {
    content: string;            // 用户消息内容
    files?: string[];           // 关联的文件 ID 列表（可选）
  };
  newTopic?: {
    topicMessageIds?: string[]; // 关联的消息 ID 列表（可选）
    title?: string;             // 主题标题
  };
  newAssistantMessage: {
    model: string;              // AI 模型名称，如 "gpt-5-mini"
    provider: string;           // 提供商，如 "openai"
  };
}
```

**HTTP 示例**:

```bash
# POST，batch=1
curl --location 'https://chat-dev.ainft.com/trpc/lambda/aiChat.sendMessageInServer?batch=1' \
  -H 'Content-Type: application/json' \
  -H 'x-ainft-chat-auth: YOUR_AUTH_TOKEN' \
  --data '{
    "0": {
      "json": {
        "newUserMessage": {
          "content": "你好",
          "files": []
        },
        "newTopic": {
          "topicMessageIds": [],
          "title": "新对话"
        },
        "newAssistantMessage": {
          "model": "gpt-5-mini",
          "provider": "openai"
        }
      }
    }
  }'
```

**返回数据**:

```typescript
{
  assistantMessageId: string;    // AI 回复消息 ID
  isCreateNewTopic: boolean;     // 是否创建了新主题
  messages: Array<{
    id: string;
    role: 'user' | 'assistant';
    content: string;
    reasoning: string | null;
    search: any | null;
    metadata: any | null;
    error: any | null;
    createdAt: string;
    updatedAt: string;
    topicId: string;
    parentId: string | null;
    threadId: string | null;
    groupId: string | null;
    agentId: string | null;
    targetId: string | null;
    tools: any | null;
    tool_call_id: string | null;
    plugin: any | null;
    pluginError: any | null;
    pluginState: any | null;
    chunksList: any[];
    extra: {
      fromModel: string | null;
      fromProvider: string | null;
      translate: any | null;
      tts: any | null;
    };
    fileList: any[];
    imageList: any[];
    meta: object;
    ragQuery: string | null;
    ragQueryId: string | null;
    ragRawQuery: string | null;
    videoList: any[];
  }>;
  topicId: string;               // 主题 ID
  topics: Array<{
    createdAt: string;
    favorite: boolean;
    historySummary: any | null;
    id: string;
    metadata: any | null;
    title: string;
    updatedAt: string;
  }>;
  userMessageId: string;         // 用户消息 ID
}
```

**返回示例**:

```json
{
  "result": {
    "data": {
      "json": {
        "assistantMessageId": "msg_RQmAu8qVbLN6DE",
        "isCreateNewTopic": true,
        "messages": [
          {
            "id": "msg_sRcEAAGiTRUCGp",
            "role": "user",
            "content": "你好",
            "reasoning": null,
            "search": null,
            "metadata": null,
            "error": null,
            "createdAt": "2026-02-24T03:53:52.116Z",
            "updatedAt": "2026-02-24T03:53:52.116Z",
            "topicId": "tpc_2qy0MSgiJRkG",
            "parentId": null,
            "threadId": null,
            "groupId": null,
            "agentId": null,
            "targetId": null,
            "tools": null,
            "tool_call_id": null,
            "plugin": null,
            "pluginError": null,
            "pluginState": null,
            "chunksList": [],
            "extra": {
              "fromModel": null,
              "fromProvider": null,
              "translate": null,
              "tts": null
            },
            "fileList": [],
            "imageList": [],
            "meta": {},
            "ragQuery": null,
            "ragQueryId": null,
            "ragRawQuery": null,
            "videoList": []
          },
          {
            "id": "msg_RQmAu8qVbLN6DE",
            "role": "assistant",
            "content": "...",
            "reasoning": null,
            "search": null,
            "metadata": null,
            "error": null,
            "createdAt": "2026-02-24T03:53:52.122Z",
            "updatedAt": "2026-02-24T03:53:52.122Z",
            "topicId": "tpc_2qy0MSgiJRkG",
            "parentId": "msg_sRcEAAGiTRUCGp",
            "threadId": null,
            "groupId": null,
            "agentId": null,
            "targetId": null,
            "tools": null,
            "tool_call_id": null,
            "plugin": null,
            "pluginError": null,
            "pluginState": null,
            "chunksList": [],
            "extra": {
              "fromModel": "gpt-5-mini",
              "fromProvider": "openai",
              "translate": null,
              "tts": null
            },
            "fileList": [],
            "imageList": [],
            "meta": {},
            "ragQuery": null,
            "ragQueryId": null,
            "ragRawQuery": null,
            "videoList": []
          }
        ],
        "topicId": "tpc_2qy0MSgiJRkG",
        "topics": [
          {
            "createdAt": "2026-02-24T03:53:52.110Z",
            "favorite": false,
            "historySummary": null,
            "id": "tpc_2qy0MSgiJRkG",
            "metadata": null,
            "title": "新对话",
            "updatedAt": "2026-02-24T03:53:52.110Z"
          }
        ],
        "userMessageId": "msg_sRcEAAGiTRUCGp"
      }
    }
  }
}
```

**说明**:

- 此接口用于在服务端创建新的对话主题并发送消息
- 会自动创建用户消息和 AI 回复消息（初始内容为 LOADING_FLAT）
- 返回的消息数组包含用户消息（role: user）和 AI 回复（role: assistant）
- `assistantMessageId` 可用于后续获取完整的 AI 流式回复
- `isCreateNewTopic` 为 `true` 表示创建了新主题
- `extra.fromModel` 和 `extra.fromProvider` 记录了实际使用的模型和提供商
- **积分检查**: 如果用户使用系统 API Key（非自定义 API Key），会检查积分余额，余额必须大于 0
- **来源类型**: `sourceType` 根据认证方式自动设置，API Key 认证为 `api`，浏览器登录为 `web`

**错误**:

- `FORBIDDEN` (403): 积分余额不足（`Insufficient points balance. Please recharge your account.`）

---

### outputJSON

生成结构化的 JSON 输出（使用 AI 模型根据 schema 生成对象）。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  provider: string;           // AI 提供商，如 "openai"
  model: string;              // AI 模型名称
  messages: Array<{           // 对话消息列表
    role: 'user' | 'assistant' | 'system';
    content: string;
  }>;
  schema: object;             // JSON Schema 定义输出结构
  tools?: any[];              // 可选的工具定义
  keyVaultsPayload: string;   // 加密的密钥库载荷
}
```

**HTTP 示例**:

```bash
# POST，batch=1
curl --location 'https://chat-dev.ainft.com/trpc/lambda/aiChat.outputJSON?batch=1' \
  -H 'Content-Type: application/json' \
  -H 'x-ainft-chat-auth: YOUR_AUTH_TOKEN' \
  --data '{
    "0": {
      "json": {
        "provider": "openai",
        "model": "gpt-4o-mini",
        "messages": [
          {"role": "user", "content": "提取以下文本中的姓名和年龄：张三今年25岁"}
        ],
        "schema": {
          "type": "object",
          "properties": {
            "name": {"type": "string"},
            "age": {"type": "number"}
          },
          "required": ["name", "age"]
        },
        "keyVaultsPayload": "..."
      }
    }
  }'
```

**返回数据**:

```typescript
{
  // 根据提供的 schema 生成的对象
  [key: string]: any;
}
```

**说明**:

- 使用 AI 模型根据提供的 JSON Schema 生成结构化输出
- `keyVaultsPayload` 需要通过 `getXorPayload` 解密获取用户密钥
- 适用于需要 AI 返回结构化数据的场景（如信息提取、分类等）

**错误**:

- `BAD_REQUEST`: `keyVaultsPayload` 不正确或解密失败

---

## 使用示例

### 发送消息创建新对话（OpenAI）

```typescript
const result = await trpc.aiChat.sendMessageInServer.mutate({
  newUserMessage: {
    content: '你好，请介绍一下自己',
    files: []
  },
  newTopic: {
    title: '新对话'
  },
  newAssistantMessage: {
    model: 'gpt-5-mini',
    provider: 'openai'
  }
});

console.log('用户消息ID:', result.userMessageId);
console.log('AI回复ID:', result.assistantMessageId);
console.log('主题ID:', result.topicId);
console.log('是否新主题:', result.isCreateNewTopic);
```

### 使用 OpenRouter 发送消息

```typescript
const result = await trpc.aiChat.sendMessageInServer.mutate({
  newUserMessage: {
    content: '123',
    files: []
  },
  newTopic: {
    topicMessageIds: [],
    title: '新对话'
  },
  newAssistantMessage: {
    model: 'qwen/qwen3-30b-a3b',  // OpenRouter 模型格式
    provider: 'openrouter'
  }
});

console.log('AI回复ID:', result.assistantMessageId);
console.log('返回主题数:', result.topics.length);  // 包含历史主题
```

### 生成结构化 JSON 输出

```typescript
const result = await trpc.aiChat.outputJSON.mutate({
  provider: 'openai',
  model: 'gpt-4o-mini',
  messages: [
    { role: 'user', content: '提取姓名和年龄：张三今年25岁' }
  ],
  schema: {
    type: 'object',
    properties: {
      name: { type: 'string' },
      age: { type: 'number' }
    },
    required: ['name', 'age']
  },
  keyVaultsPayload: encryptedPayload
});

console.log(result); // { name: '张三', age: 25 }
```

---

详细接口文档参见源码：`src/server/routers/lambda/aiChat.ts`
