# POST /webapi/chat/:provider

AI 聊天流式响应接口，支持多种 AI 提供商。

## 接口信息

**方法**: `POST`

**路径**: `/webapi/chat/:provider`

**超时**: 300 秒

**认证**: 需要 JWT Token

## 路径参数

- `provider`: AI 提供商名称（如 `openai`, `anthropic`, `google` 等）

## 请求体

```typescript
{
  messages: Array<{
    role: 'user' | 'assistant' | 'system' | 'tool';
    content: string;
    name?: string;
  }>;
  model: string;                    // 模型名称
  stream?: boolean;                 // 是否流式响应（默认 true）
  temperature?: number;             // 温度（0-2）
  top_p?: number;                   // Top-p 采样
  max_tokens?: number;              // 最大令牌数
  presence_penalty?: number;        // 存在惩罚
  frequency_penalty?: number;       // 频率惩罚
  tools?: Array<{
    type: 'function';
    function: {
      name: string;
      description: string;
      parameters: object;
    };
  }>;
  tool_choice?: 'auto' | 'none' | object;
}
```

## 响应

### 流式响应（默认）

**Content-Type**: `text/event-stream`

每个事件格式：

```
data: {"id":"chatcmpl-xxx","object":"chat.completion.chunk","created":1234567890,"model":"gpt-4","choices":[{"index":0,"delta":{"content":"你好"},"finish_reason":null}]}

data: [DONE]
```

### 非流式响应

**Content-Type**: `application/json`

```typescript
{
  id: string;
  object: 'chat.completion';
  created: number;
  model: string;
  choices: Array<{
    index: number;
    message: {
      role: 'assistant';
      content: string;
    };
    finish_reason: 'stop' | 'length' | 'tool_calls';
  }>;
  usage: {
    prompt_tokens: number;
    completion_tokens: number;
    total_tokens: number;
  };
}
```

## 特殊功能

### 积分预扣

接口会自动处理积分预扣和结算：

1. **预估消耗**: 根据输入令牌数预估积分消耗
2. **预扣积分**: 在生成前扣除预估积分
3. **实时扩展**: 如果生成超出预估，动态扩展预扣额度
4. **最终结算**: 完成后根据实际使用结算，退还多余积分

### API Key 轮询

支持系统级 API Key 池：

- 自动轮询可用的 API Key
- 检测并处理失败的 Key（速率限制、无效等）
- 最多重试 3 次

### 错误处理

接口会捕获并处理以下错误：

- **API Key 错误**: 无效、过期、配额不足
- **速率限制**: 自动切换到备用 Key
- **模型不可用**: 返回明确错误信息
- **内容过滤**: OpenAI 内容策略违规

## 使用示例

### 基础对话

```typescript
const response = await fetch('/webapi/chat/openai', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    messages: [
      { role: 'system', content: '你是一个有用的助手' },
      { role: 'user', content: '介绍一下你自己' }
    ],
    model: 'gpt-4',
    temperature: 0.7,
    max_tokens: 2000
  })
});

// 处理流式响应
const reader = response.body.getReader();
const decoder = new TextDecoder();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  
  const chunk = decoder.decode(value);
  const lines = chunk.split('\n');
  
  for (const line of lines) {
    if (line.startsWith('data: ')) {
      const data = line.slice(6);
      if (data === '[DONE]') {
        console.log('完成');
        break;
      }
      
      try {
        const json = JSON.parse(data);
        const content = json.choices[0]?.delta?.content || '';
        process.stdout.write(content);
      } catch (e) {
        // 忽略解析错误
      }
    }
  }
}
```

### 工具调用（Function Calling）

```typescript
const response = await fetch('/webapi/chat/openai', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    messages: [
      { role: 'user', content: '今天北京的天气怎么样？' }
    ],
    model: 'gpt-4',
    tools: [
      {
        type: 'function',
        function: {
          name: 'get_weather',
          description: '获取指定城市的天气',
          parameters: {
            type: 'object',
            properties: {
              city: {
                type: 'string',
                description: '城市名称'
              }
            },
            required: ['city']
          }
        }
      }
    ],
    tool_choice: 'auto'
  })
});
```

### 使用前端 SDK

```typescript
import { createOpenAI } from '@ai-sdk/openai';

// 配置自定义端点
const openai = createOpenAI({
  baseURL: '/webapi/chat/openai',
  apiKey: token
});

// 流式对话
const { textStream } = await openai.chat.completions.create({
  model: 'gpt-4',
  messages: [
    { role: 'user', content: '你好' }
  ],
  stream: true
});

for await (const chunk of textStream) {
  process.stdout.write(chunk);
}
```

## 支持的提供商

- `openai` - OpenAI GPT 系列
- `anthropic` - Claude 系列
- `google` - Gemini 系列
- `azure` - Azure OpenAI
- `azureai` - Azure AI Studio
- `ollama` - 本地 Ollama 模型
- 更多...（参见 `model-bank` 包）

## 错误响应

```typescript
{
  error: {
    message: string;
    type: string;
    code?: string;
  }
}
```

常见错误：

- `401`: 未授权（Token 无效）
- `400`: 请求参数错误
- `403`: 积分不足
- `429`: 速率限制
- `500`: 服务器错误
- `502`: 上游 API 错误

## 性能优化

### 流式响应优势

- 降低首字节时间（TTFB）
- 改善用户体验（逐字显示）
- 减少客户端等待时间

### 积分预扣策略

```typescript
// 预估倍率：1.5x
// 假设输入 1000 tokens，模型单价 10 points/1k tokens
const estimatedCost = 1000 * 10 / 1000 * 1.5 = 15 points

// 如果生成超过预估，自动扩展
if (actualTokens > estimatedTokens) {
  await extendPrededuct();
}

// 完成后结算
const actualCost = actualTokens * 10 / 1000;
await settleCredits(actualCost, estimatedCost);
```

## 限制

- **最大超时**: 300 秒
- **最大令牌数**: 由模型决定（如 GPT-4 为 128k）
- **速率限制**: 由提供商决定
- **并发限制**: 服务端配置

## 追踪

接口会自动上报追踪数据（如果启用）：

- 请求参数
- 响应时间
- Token 使用量
- 错误信息

使用 OpenTelemetry 协议。

## 安全性

### JWT 验证

- 必须提供有效的 JWT Token
- Token 包含 userId 和权限信息

### 内容过滤

- OpenAI 提供商会自动过滤不当内容
- 其他提供商根据各自政策

### API Key 保护

- 用户 API Key 优先
- 系统 API Key 加密存储
- Key 失败会自动标记和切换

## 相关接口

- [POST /webapi/trace](./trace.md) - 追踪数据上报
- [POST /webapi/tokenizer](./tokenizer.md) - 令牌计数
