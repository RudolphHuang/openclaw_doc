# AI Provider AI 提供商管理接口

管理 AI 服务提供商配置。

## 主要接口

### getAiProviderRuntimeState

获取 AI 提供商运行时状态，包括所有启用的模型和提供商配置。

**类型**: `query`

**权限**: 公开/需要认证

**输入参数**:

```typescript
{
  isLogin?: boolean | null;  // 是否已登录（可选）
}
```

**HTTP 示例**:

```bash
# GET，batch=1
curl 'https://chat-dev.ainft.com/trpc/lambda/aiProvider.getAiProviderRuntimeState?batch=1&input=%7B%220%22%3A%7B%22json%22%3A%7B%22isLogin%22%3Anull%7D%2C%22meta%22%3A%7B%22values%22%3A%7B%22isLogin%22%3A%5B%22undefined%22%5D%7D%2C%22v%22%3A1%7D%7D%7D' \
  -H 'accept: */*'
```

**返回数据**:

```typescript
{
  enabledAiModels: Array<{
    id: string;                    // 模型 ID
    displayName: string;           // 显示名称
    description: string;           // 描述
    descriptionLink: string;       // 文档链接
    contextWindowTokens: number;   // 上下文窗口大小
    maxOutput: number;             // 最大输出 token
    type: string;                  // 类型："chat" | "image"
    providerId: string;            // 提供商 ID
    source: string;                // 来源："builtin" | "custom"
    enabled: boolean;              // 是否启用
    isMaintenance: boolean;        // 是否维护中
    abilities: {
      companyLabel?: string;       // 公司标签
      vision?: boolean;            // 是否支持视觉
      reasoning?: boolean;         // 是否支持推理
      flagship?: boolean;          // 是否为旗舰模型
    };
    pricing: {
      units: Array<{
        name: string;              // 计费项名称
        rate: number;              // 费率
        strategy: string;          // 计费策略
        unit: string;              // 单位
      }>;
    };
    pointPricing: {
      units: Array<{
        name: string;              // inputPrice | outputPrice
        cost: number;              // 积分成本
      }>;
    };
    settings: {
      extendParams?: string[];     // 扩展参数
      searchImpl?: string;         // 搜索实现
      searchProvider?: string;     // 搜索提供商
    };
    releasedAt: string;            // 发布日期
  }>;
  enabledAiProviders: Array<{
    id: string;                    // 提供商 ID
    name: string;                  // 提供商名称
    source: string;                // 来源
  }>;
  enabledChatAiProviders: Array<{
    id: string;
    name: string;
    source: string;
  }>;
  enabledImageAiProviders: Array<{
    id: string;
    name: string;
    source: string;
  }>;
  runtimeConfig: {
    [providerId: string]: {
      config: object;
      fetchOnClient: boolean | null;
      keyVaults: object;
      settings: {
        showModelFetcher?: boolean;
        sdkType?: string;
        proxyUrl?: { placeholder: string };
        // ... 其他设置
      };
    };
  };
}
```

**返回示例**:

```json
{
  "result": {
    "data": {
      "json": {
        "enabledAiModels": [
          {
            "id": "gpt-5.2",
            "displayName": "GPT-5.2",
            "description": "GPT-5.2 is a flagship model for coding and agentic workflows...",
            "contextWindowTokens": 400000,
            "maxOutput": 128000,
            "type": "chat",
            "providerId": "openai",
            "source": "builtin",
            "enabled": true,
            "abilities": {
              "companyLabel": "OpenAI",
              "flagship": true,
              "vision": true
            },
            "pricing": {
              "units": [
                { "name": "textInput", "rate": 1.75, "strategy": "fixed", "unit": "millionTokens" },
                { "name": "textOutput", "rate": 14, "strategy": "fixed", "unit": "millionTokens" }
              ]
            },
            "pointPricing": {
              "units": [
                { "name": "inputPrice", "cost": 1.75 },
                { "name": "outputPrice", "cost": 14 }
              ]
            }
          }
        ],
        "enabledAiProviders": [
          { "id": "openai", "name": "OpenAI", "source": "builtin" },
          { "id": "anthropic", "name": "Anthropic", "source": "builtin" },
          { "id": "google", "name": "Google", "source": "builtin" },
          { "id": "openrouter", "name": "OpenRouter", "source": "builtin" }
        ],
        "enabledChatAiProviders": [
          { "id": "openai", "name": "OpenAI", "source": "builtin" },
          { "id": "anthropic", "name": "Anthropic", "source": "builtin" },
          { "id": "google", "name": "Google", "source": "builtin" },
          { "id": "openrouter", "name": "OpenRouter", "source": "builtin" }
        ],
        "runtimeConfig": {
          "openai": {
            "settings": { "showModelFetcher": true, "supportResponsesApi": true }
          },
          "openrouter": {
            "settings": { 
              "sdkType": "openai",
              "proxyUrl": { "placeholder": "https://openrouter.ai/api/v1" }
            }
          }
        }
      }
    }
  }
}
```

**说明**:
- 返回系统所有启用的 AI 模型和提供商配置
- 包含模型的详细能力、定价信息（美元计费和积分计费）
- `enabledChatAiProviders` 是支持聊天的提供商子集
- `runtimeConfig` 包含各提供商的运行时配置

---

### getAIProviders

获取所有 AI 提供商列表。

**类型**: `query`

**权限**: 需要认证

**返回数据**:

```typescript
Array<{
  id: string;
  name: string;
  displayName?: string;
  description?: string;
  logo?: string;
  enabled?: boolean;
  requiresApiKey?: boolean;
}>
```

---

### enableAIProvider

启用指定提供商。

**类型**: `mutation`

**权限**: 需要认证

---

### configureAIProvider

配置提供商（如 API Key、Base URL 等）。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  providerId: string;
  config: {
    apiKey?: string;
    baseURL?: string;
    // ... 其他配置
  };
}
```

---

## 使用示例

```typescript
// 配置 OpenAI
await trpc.aiProvider.configureAIProvider.mutate({
  providerId: 'openai',
  config: {
    apiKey: 'sk-...',
    baseURL: 'https://api.openai.com/v1'
  }
});

// 启用提供商
await trpc.aiProvider.enableAIProvider.mutate({
  providerId: 'openai'
});
```

详细接口文档参见源码：`src/server/routers/lambda/aiProvider.ts`
