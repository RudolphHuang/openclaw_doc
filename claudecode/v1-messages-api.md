# Claude 兼容接口 /v1/messages 技术文档

## 概述

Claude 兼容接口提供了与 Anthropic Messages API 兼容的 REST 端点，路径为 `/v1/messages`。该接口将 Claude API 请求转换为内部 Provider API 调用，并将响应转换回 Claude 格式。

## 架构图

```mermaid
flowchart TB
    subgraph Client["客户端"]
        A[Claude API Client]
    end

    subgraph API["API 层"]
        B["/v1/messages"]
        C[Claude Error Handler]
    end

    subgraph Handler["Handler 层"]
        D[handleMessagesPOST]
        E[模型解析]
        F[流式/非流式处理]
    end

    subgraph Transform["转换层"]
        G[Claude → Provider 请求转换]
        H[SSE → Claude 响应转换]
        I[OpenAI Chunk → Claude 格式]
    end

    subgraph Provider["Provider 层"]
        J[ProviderPOST]
        K[各种 LLM Provider]
    end

    A -->|Claude API Request| B
    B --> C
    C --> D
    D --> E
    E -->|resolveModelProvider| F
    F --> G
    G --> J
    J --> K
    K -->|SSE/JSON Response| H
    H -->|转换| I
    I -->|Claude API Response| A
```

## 时序图

```mermaid
sequenceDiagram
    autonumber
    participant C as Claude API Client
    participant R as /v1/messages
    participant H as Handler
    participant M as ModelResolver
    participant P as ProviderPOST
    participant U as Upstream Provider

    C->>R: POST /v1/messages<br/>{model, messages, stream}
    R->>H: handleMessagesPOST(req)

    alt 无效 JSON
        H-->>C: 400 Invalid JSON
    else 缺少 model
        H-->>C: 400 Missing model
    else 缺少 messages
        H-->>C: 400 Missing messages
    end

    H->>M: resolveModelProvider(model)
    M-->>H: {provider, model}

    alt 无法解析 Provider
        H-->>C: 404 Provider not found
    end

    H->>H: normalizeStreamFlag(stream)

    H->>P: ProviderPOST(forwardedReq, {provider})
    P->>U: 转发请求

    alt 流式响应 stream=true
        U-->>P: SSE Stream
        P-->>H: SSE Response
        H->>H: convertProviderSSEToClaudeStream
        loop 每个 SSE Block
            H->>H: 解析 event/data
            H->>H: 转换为 Claude 格式
        end
        H-->>C: SSE Stream<br/>message_start → content_block_delta → message_stop
    else 非流式响应 stream=false
        U-->>P: SSE/JSON
        P-->>H: Response
        H->>H: convertSSEToJSONResponse
        H->>H: 聚合内容/工具调用
        H-->>C: JSON Response<br/>{id, content, role, stop_reason}
    end

    alt Provider 错误
        U-->>P: Error Response
        P-->>H: Error
        H->>H: toClaudeErrorResponse
        H-->>C: Claude 格式错误响应
    end
```

## 请求处理流程图

```mermaid
flowchart LR
    A[接收请求] --> B{验证请求体}
    B -->|无效| C[返回 400]
    B -->|有效| D{检查 model}
    D -->|缺少| E[返回 400]
    D -->|存在| F{解析 Provider}
    F -->|失败| G[返回 404]
    F -->|成功| H{检查 messages}
    H -->|缺少| I[返回 400]
    H -->|存在| J{解析 stream}
    J -->|无效| K[返回 400]
    J -->|有效| L[转发请求到 Provider]
    L --> M{响应类型}
    M -->|SSE + stream=true| N[流式转换]
    M -->|SSE + stream=false| O[聚合转换]
    M -->|JSON| P[直接转换]
    M -->|错误| Q[错误处理]
    N --> R[返回 Claude SSE]
    O --> S[返回 Claude JSON]
    P --> S
    Q --> T[返回 Claude 错误]
```

## 响应转换流程

### 流式响应转换

```mermaid
flowchart TB
    subgraph Input["Provider SSE 输入"]
        A1[event: text<br/>data: "你好"]
        A2[event: text<br/>data: "，世界"]
        A3[event: stop<br/>data: "stop"]
    end

    subgraph Process["转换处理"]
        B1[解析 SSE Block]
        B2[识别 event 类型]
        B3{event 类型}
        B4[累积文本内容]
        B5[生成 content_block_start]
        B6[生成 content_block_delta]
        B7[生成 message_delta]
        B8[生成 message_stop]
    end

    subgraph Output["Claude SSE 输出"]
        C1[message_start]
        C2[content_block_start]
        C3[content_block_delta × N]
        C4[message_delta]
        C5[message_stop]
    end

    A1 --> B1
    A2 --> B1
    A3 --> B1
    B1 --> B2
    B2 --> B3
    B3 -->|text| B4
    B3 -->|stop| B7
    B4 --> B5
    B5 --> C2
    B4 --> B6
    B6 --> C3
    B7 --> B8
    B8 --> C4
    B8 --> C5
    C1 --> C2 --> C3 --> C4 --> C5
```

### 非流式响应转换

```mermaid
flowchart LR
    A[接收 Provider SSE] --> B[按 \n\n 分割 Blocks]
    B --> C[遍历每个 Block]
    C --> D[解析 event/data]
    D --> E{event 类型}
    E -->|text| F[累积 content]
    E -->|tool_calls| G[累积 tool_calls]
    E -->|stop| H[记录 stop_reason]
    E -->|usage| I[记录 usage]
    F --> J[构建 Claude Response]
    G --> J
    H --> J
    I --> J
    J --> K[返回 JSON]

    L[接收 OpenAI JSON] --> M[提取 choices]
    M --> N[提取 content]
    M --> O[提取 tool_calls]
    M --> P[提取 usage]
    N --> J
    O --> J
    P --> J
```

## 错误处理流程

```mermaid
flowchart TB
    subgraph ErrorSource["错误来源"]
        A1[无效请求 400]
        A2[未授权 401]
        A3[未找到 404]
        A4[限流 429]
        A5[服务器错误 5xx]
    end

    subgraph ErrorMapping["错误映射"]
        B1{状态码映射}
        B2[type: invalid_request_error]
        B3[type: authentication_error]
        B4[type: not_found_error]
        B5[type: rate_limit_error]
        B6[type: api_error]
    end

    subgraph ClaudeError["Claude 错误格式"]
        C1["{ error: { message, type } }"]
    end

    A1 --> B1
    A2 --> B1
    A3 --> B1
    A4 --> B1
    A5 --> B1
    B1 -->|400| B2
    B1 -->|401| B3
    B1 -->|404| B4
    B1 -->|429| B5
    B1 -->|5xx| B6
    B2 --> C1
    B3 --> C1
    B4 --> C1
    B5 --> C1
    B6 --> C1
```

## API 端点

### POST /v1/messages

创建一个新的消息完成。

#### 请求格式

```typescript
interface ClaudeMessagesRequest {
  model: string;
  messages: Array<{
    role: 'user' | 'assistant';
    content: string | Array<ContentBlock>;
  }>;
  max_tokens?: number;
  stream?: boolean;
  system?: string;
  tools?: Array<{
    name: string;
    description: string;
    input_schema: object;
  }>;
}
```

#### 响应格式

**非流式响应:**
```typescript
interface ClaudeMessageResponse {
  id: string;
  type: 'message';
  role: 'assistant';
  content: Array<TextBlock | ToolUseBlock>;
  model: string;
  stop_reason: 'end_turn' | 'max_tokens' | 'stop_sequence' | 'tool_use';
  stop_sequence: string | null;
  usage?: {
    input_tokens: number;
    output_tokens: number;
  };
}
```

**流式响应:**
```typescript
// message_start
type MessageStartEvent = {
  type: 'message_start';
  message: {
    id: string;
    type: 'message';
    role: 'assistant';
    content: [];
    model: string;
    stop_reason: null;
    stop_sequence: null;
  };
};

// content_block_start
type ContentBlockStartEvent = {
  type: 'content_block_start';
  index: number;
  content_block: {
    type: 'text';
    text: string;
  };
};

// content_block_delta
type ContentBlockDeltaEvent = {
  type: 'content_block_delta';
  index: number;
  delta: {
    type: 'text_delta';
    text: string;
  };
};

// message_delta
type MessageDeltaEvent = {
  type: 'message_delta';
  delta: {
    stop_reason: string;
  };
  usage?: {
    input_tokens: number;
    output_tokens: number;
  };
};

// message_stop
type MessageStopEvent = {
  type: 'message_stop';
};
```

## 文件结构

```
src/app/(backend)/v1/messages/
├── route.ts          # 路由入口，导出 POST handler 和 maxDuration
├── handler.ts        # 核心处理逻辑
└── route.test.ts     # 单元测试

src/app/(backend)/v1/_utils/
├── claudeError.ts    # Claude 错误处理工具
```

## 关键函数说明

| 函数名 | 作用 |
|--------|------|
| `handleMessagesPOST` | 主处理函数，协调请求验证、Provider 调用、响应转换 |
| `convertProviderSSEToClaudeStream` | 将 Provider SSE 流转换为 Claude SSE 格式 |
| `convertSSEToJSONResponse` | 将 Provider SSE 聚合为 Claude JSON 响应 |
| `mapFinishReason` | 映射 finish_reason (stop → end_turn, tool_calls → tool_use) |
| `normalizeStreamFlag` | 规范化 stream 参数 (支持 boolean/string/number) |
| `createClaudeErrorResponse` | 创建 Claude 格式的错误响应 |

## 与 OpenAI 接口对比

```mermaid
flowchart LR
    subgraph OpenAI["OpenAI 兼容接口"]
        A1["/v1/chat/completions"]
        A2[OpenAI Error Format]
        A3[chat.completion.chunk]
        A4[finish_reason: stop]
    end

    subgraph Claude["Claude 兼容接口"]
        B1["/v1/messages"]
        B2[Claude Error Format]
        B3[content_block_delta]
        B4[stop_reason: end_turn]
    end

    subgraph Common["共用部分"]
        C1[Provider 路由]
        C2[模型解析]
        C3[认证中间件]
    end

    A1 --> C1
    B1 --> C1
    C1 --> C2
    C2 --> C3
```