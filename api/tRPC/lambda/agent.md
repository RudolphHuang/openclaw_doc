# Agent 管理接口

Agent 是 AI 助手的配置，包括系统提示词、知识库、文件等。

## 接口列表

### getAgentConfig

获取指定会话的 Agent 配置。

**类型**: `query`

**权限**: 需要认证

**输入参数**:

```typescript
{
  sessionId: string;  // 会话 ID，如 "inbox" 表示收件箱
}
```

**HTTP 示例**:

```bash
# GET，batch=1
curl 'https://chat-dev.ainft.com/trpc/lambda/agent.getAgentConfig?batch=1&input=%7B%220%22%3A%7B%22json%22%3A%7B%22sessionId%22%3A%22inbox%22%7D%7D%7D' \
  -H 'accept: */*' \
  -H 'x-ainft-chat-auth: YOUR_AUTH_TOKEN'
```

**返回数据**:

```typescript
{
  id: string;                    // Agent ID
  slug: string;                  // 唯一标识符
  title: string | null;          // 标题
  description: string | null;    // 描述
  tags: string[];                // 标签列表
  avatar: string | null;         // 头像 URL
  backgroundColor: string | null; // 背景色
  plugins: string[];             // 启用的插件列表
  clientId: string | null;       // 客户端 ID
  userId: string;                // 所属用户 ID
  chatConfig: {                  // 聊天配置
    searchMode: string;          // 搜索模式："off" | "on"
    displayMode: string;         // 显示模式："chat" | "docs"
    historyCount: number;        // 历史消息数量
    searchFCModel: {             // 搜索模型配置
      model: string;
      provider: string;
    };
    enableReasoning: boolean;    // 是否启用推理
    enableStreaming: boolean;    // 是否启用流式输出
    enableHistoryCount: boolean; // 是否启用历史计数
    reasoningBudgetToken: number; // 推理预算 token
    enableAutoCreateTopic: boolean; // 是否自动创建主题
    enableCompressHistory: boolean; // 是否压缩历史
    autoCreateTopicThreshold: number; // 自动创建主题阈值
  };
  fewShots: any | null;          // Few-shot 示例
  model: string;                 // AI 模型名称
  params: {                      // 模型参数
    top_p: number;
    temperature: number;
    presence_penalty: number;
    frequency_penalty: number;
  };
  provider: string;              // 模型提供商
  systemRole: string;            // 系统角色提示词
  tts: {                         // 语音配置
    voice: object;
    sttLocale: string;
    ttsService: string;
    showAllLocaleVoice: boolean;
  };
  virtual: boolean;              // 是否为虚拟 Agent
  openingMessage: string | null; // 开场消息
  openingQuestions: string[];    // 开场问题列表
  accessedAt: string;            // 最后访问时间
  createdAt: string;             // 创建时间
  updatedAt: string;             // 更新时间
  files: any[];                  // 绑定的文件列表
  knowledgeBases: any[];         // 绑定的知识库列表
}
```

**返回示例**:

```json
{
  "result": {
    "data": {
      "json": {
        "id": "agt_5PH1HEivg9aL",
        "slug": "planned-flies-voice-class",
        "title": null,
        "description": null,
        "tags": [],
        "avatar": null,
        "backgroundColor": null,
        "plugins": [],
        "clientId": null,
        "userId": "TMujsbV6t2weXmoPrdfc8QAMJ3oZCJFBXo",
        "chatConfig": {
          "searchMode": "off",
          "displayMode": "chat",
          "historyCount": 20,
          "searchFCModel": {
            "model": "gpt-5-mini",
            "provider": "openai"
          },
          "enableReasoning": false,
          "enableStreaming": true,
          "enableHistoryCount": true,
          "reasoningBudgetToken": 1024,
          "enableAutoCreateTopic": true,
          "enableCompressHistory": true,
          "autoCreateTopicThreshold": 2
        },
        "fewShots": null,
        "model": "qwen/qwen3-30b-a3b",
        "params": {
          "top_p": 1,
          "temperature": 1,
          "presence_penalty": 0,
          "frequency_penalty": 0
        },
        "provider": "openrouter",
        "systemRole": "",
        "tts": {
          "voice": {
            "openai": "alloy"
          },
          "sttLocale": "auto",
          "ttsService": "openai",
          "showAllLocaleVoice": false
        },
        "virtual": false,
        "openingMessage": null,
        "openingQuestions": [],
        "accessedAt": "2026-02-05T07:46:20.835Z",
        "createdAt": "2026-02-05T07:46:20.836Z",
        "updatedAt": "2026-02-05T07:46:20.836Z",
        "files": [],
        "knowledgeBases": []
      }
    }
  }
}
```

**说明**:

- 如果会话是 INBOX（收件箱），会自动创建默认配置
- 如果会话不存在，会抛出错误
- 返回的 `model` 和 `provider` 表示当前使用的 AI 模型和提供商
- `chatConfig` 包含聊天行为的详细配置

---

### getKnowledgeBasesAndFiles

获取可用的知识库和文件列表（用于 Agent 绑定）。

**类型**: `query`

**权限**: 需要认证

**输入参数**:

```typescript
{
  agentId: string;
}
```

**返回数据**:

```typescript
Array<{
  id: string;
  name: string;
  type: 'file' | 'knowledgeBase';
  enabled: boolean;  // 是否已绑定到该 Agent
  fileType?: string;
  description?: string;
  avatar?: string;
}>
```

**说明**:

- 返回所有可用的知识库和文件（过滤图片文件）
- `enabled` 表示是否已绑定到指定 Agent

---

### createAgentFiles

为 Agent 绑定文件。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  agentId: string;
  fileIds: string[];
  enabled?: boolean;  // 默认 true
}
```

**返回数据**:

```typescript
void
```

---

### deleteAgentFile

解除 Agent 与文件的绑定。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  agentId: string;
  fileId: string;
}
```

**返回数据**:

```typescript
void
```

---

### toggleFile

切换文件在 Agent 中的启用状态。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  agentId: string;
  fileId: string;
  enabled?: boolean;  // 可选，不提供则切换状态
}
```

**返回数据**:

```typescript
void
```

---

### createAgentKnowledgeBase

为 Agent 绑定知识库。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  agentId: string;
  knowledgeBaseId: string;
  enabled?: boolean;  // 默认 true
}
```

**返回数据**:

```typescript
void
```

---

### deleteAgentKnowledgeBase

解除 Agent 与知识库的绑定。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  agentId: string;
  knowledgeBaseId: string;
}
```

**返回数据**:

```typescript
void
```

---

### toggleKnowledgeBase

切换知识库在 Agent 中的启用状态。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  agentId: string;
  knowledgeBaseId: string;
  enabled?: boolean;  // 可选，不提供则切换状态
}
```

**返回数据**:

```typescript
void
```

---

## 使用示例

### 获取 Agent 配置

```typescript
const config = await trpc.agent.getAgentConfig.query({
  sessionId: 'session-id'
});

console.log(`系统角色: ${config.systemRole}`);
console.log(`模型: ${config.model}`);
```

### 获取可绑定的知识库和文件

```typescript
const items = await trpc.agent.getKnowledgeBasesAndFiles.query({
  agentId: 'agent-id'
});

// 已启用的知识库
const enabledKB = items.filter(
  item => item.type === 'knowledgeBase' && item.enabled
);

// 已启用的文件
const enabledFiles = items.filter(
  item => item.type === 'file' && item.enabled
);

console.log(`已绑定 ${enabledKB.length} 个知识库`);
console.log(`已绑定 ${enabledFiles.length} 个文件`);
```

### 为 Agent 绑定文件

```typescript
await trpc.agent.createAgentFiles.mutate({
  agentId: 'agent-id',
  fileIds: ['file-1', 'file-2', 'file-3'],
  enabled: true
});
```

### 解除文件绑定

```typescript
await trpc.agent.deleteAgentFile.mutate({
  agentId: 'agent-id',
  fileId: 'file-id'
});
```

### 切换文件启用状态

```typescript
// 切换状态
await trpc.agent.toggleFile.mutate({
  agentId: 'agent-id',
  fileId: 'file-id'
});

// 显式禁用
await trpc.agent.toggleFile.mutate({
  agentId: 'agent-id',
  fileId: 'file-id',
  enabled: false
});
```

### 为 Agent 绑定知识库

```typescript
await trpc.agent.createAgentKnowledgeBase.mutate({
  agentId: 'agent-id',
  knowledgeBaseId: 'kb-id',
  enabled: true
});
```

### 切换知识库启用状态

```typescript
await trpc.agent.toggleKnowledgeBase.mutate({
  agentId: 'agent-id',
  knowledgeBaseId: 'kb-id',
  enabled: false
});
```

---

## 数据类型

### AgentConfig

```typescript
{
  id: string;
  sessionId: string;
  systemRole?: string;
  model?: string;
  provider?: string;
  temperature?: number;
  topP?: number;
  maxTokens?: number;
  frequencyPenalty?: number;
  presencePenalty?: number;
  plugins?: string[];
  tts?: {
    showAllLocaleVoice?: boolean;
    sttLocale?: string;
    ttsService?: string;
    voice?: {
      [provider: string]: string;
    };
  };
  chatConfig?: {
    autoCreateTopicThreshold?: number;
    displayMode?: 'chat' | 'document';
    enableAutoCreateTopic?: boolean;
    enableCompressThreshold?: boolean;
    enableHistoryCount?: boolean;
    historyCount?: number;
  };
}
```

### KnowledgeItem

```typescript
{
  id: string;
  name: string;
  type: 'file' | 'knowledgeBase';
  enabled: boolean;
  fileType?: string;        // 仅文件类型
  description?: string;     // 仅知识库类型
  avatar?: string;          // 仅知识库类型
}
```

---

## 使用场景

### 1. 配置 RAG Agent

为 Agent 绑定知识库，实现检索增强生成：

```typescript
// 1. 获取 Agent 配置
const config = await trpc.agent.getAgentConfig.query({
  sessionId: 'session-id'
});

// 2. 绑定知识库
await trpc.agent.createAgentKnowledgeBase.mutate({
  agentId: config.id,
  knowledgeBaseId: 'my-knowledge-base',
  enabled: true
});

// 3. 绑定相关文档
await trpc.agent.createAgentFiles.mutate({
  agentId: config.id,
  fileIds: ['doc-1', 'doc-2']
});
```

### 2. 动态管理 Agent 知识源

根据对话内容动态启用/禁用知识源：

```typescript
// 讨论技术问题时，启用技术文档
await trpc.agent.toggleKnowledgeBase.mutate({
  agentId: 'agent-id',
  knowledgeBaseId: 'tech-docs',
  enabled: true
});

// 切换话题时，禁用无关知识库
await trpc.agent.toggleKnowledgeBase.mutate({
  agentId: 'agent-id',
  knowledgeBaseId: 'marketing-docs',
  enabled: false
});
```

### 3. 构建 Agent 配置界面

```typescript
// 获取所有可用资源
const items = await trpc.agent.getKnowledgeBasesAndFiles.query({
  agentId: 'agent-id'
});

// 渲染 UI：知识库列表
const knowledgeBases = items.filter(item => item.type === 'knowledgeBase');
knowledgeBases.forEach(kb => {
  renderCheckbox({
    label: kb.name,
    checked: kb.enabled,
    onChange: (checked) => {
      trpc.agent.toggleKnowledgeBase.mutate({
        agentId: 'agent-id',
        knowledgeBaseId: kb.id,
        enabled: checked
      });
    }
  });
});
```
