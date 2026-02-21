# Config 全局配置接口

获取服务端全局配置，包括 AI 提供商与模型列表、功能开关（Feature Flags）等。用于前端初始化时拉取当前环境与用户维度的配置。

## 主要接口

### getGlobalConfig

获取全局运行时配置（服务端配置 + 功能开关）。

**类型**: `query`

**权限**: 公开（无需认证）。部分功能开关可能按用户 ID 动态计算。

**输入参数**: 无

**HTTP 示例**:

```bash
# GET，batch=1，无入参时 input 为 {"0":{"json":null,"meta":{"values":["undefined"],"v":1}}}
curl 'https://chat-dev.ainft.com/trpc/lambda/config.getGlobalConfig?batch=1&input=%7B%220%22%3A%7B%22json%22%3Anull%2C%22meta%22%3A%7B%22values%22%3A%5B%22undefined%22%5D%2C%22v%22%3A1%7D%7D%7D%7D' \
  -H 'accept: */*'
```

**说明**: tRPC 调用约定（base 路径、batch、input 格式）见 [tRPC README](../README.md)。返回为 batch 数组，实际数据在 `[0].result.data.json`。

**返回数据结构**:

```typescript
interface GlobalRuntimeConfig {
  /** 描述链接（可选，来自环境变量 DESCRIPTION_LINK） */
  descriptionLink?: string | null;
  /** 服务端全局配置（AI 提供商、模型、上传、OAuth 等） */
  serverConfig: GlobalServerConfig;
  /** 功能开关（按用户评估后的布尔值） */
  serverFeatureFlags: IFeatureFlagsState;
}

interface GlobalServerConfig {
  /** 各 AI 提供商的启用状态与模型列表（含定价等） */
  aiProvider: Record<string, ServerModelProviderConfig>;
  /** 默认 Agent 配置 */
  defaultAgent?: Record<string, unknown>;
  /** 是否允许上传文件到服务端 */
  enableUploadFileToServer?: boolean;
  /** 是否启用访问码 */
  enabledAccessCode?: boolean;
  /** 是否启用 OAuth SSO（已废弃） */
  enabledOAuthSSO?: boolean;
  /** 图片相关配置 */
  image?: Record<string, unknown>;
  /** 语言模型配置（与 aiProvider 结构类似，部分场景使用） */
  languageModel?: Record<string, ServerModelProviderConfig>;
  /** 支持的 OAuth SSO 提供商列表，如 github、tronlink、bybit 等 */
  oAuthSSOProviders?: string[];
  /** 系统 Agent 配置 */
  systemAgent?: Record<string, unknown>;
  /** 遥测配置 */
  telemetry?: { langfuse?: boolean };
}

/** 单个提供商的配置：是否启用、启用模型 ID 列表、服务端模型卡片/列表 */
interface ServerModelProviderConfig {
  enabled?: boolean;
  enabledModels?: string[] | null;
  fetchOnClient?: boolean;
  /** 服务端定义的模型卡片（展示用） */
  serverModelCards?: Array<{ id: string; displayName: string; enabled?: boolean; [k: string]: unknown }> | null;
  /** 服务端模型列表（含 pointPricing、pricing、contextWindowTokens 等） */
  serverModelLists?: Array<{
    id: string;
    displayName: string;
    enabled?: boolean;
    providerId?: string;
    contextWindowTokens?: number;
    maxOutput?: number;
    pointPricing?: { units: Array<{ name: string; cost?: number }> };
    pricing?: { units: Array<{ name: string; rate?: number; strategy?: string; unit?: string }> };
    description?: string;
    descriptionLink?: string;
    [k: string]: unknown;
  }> | null;
}

/** 功能开关状态（均为布尔值，按用户 ID 评估后返回） */
interface IFeatureFlagsState {
  isAgentEditable?: boolean;
  showCreateSession?: boolean;
  enableGroupChat?: boolean;
  showLLM?: boolean;
  showProvider?: boolean;
  showPinList?: boolean;
  showOpenAIApiKey?: boolean;
  showOpenAIProxyUrl?: boolean;
  showApiKeyManage?: boolean;
  enablePlugins?: boolean;
  showDalle?: boolean;
  showAiImage?: boolean;
  showChangelog?: boolean;
  enableCheckUpdates?: boolean;
  showWelcomeSuggest?: boolean;
  enableClerkSignUp?: boolean;
  enableKnowledgeBase?: boolean;
  enableRAGEval?: boolean;
  showCloudPromotion?: boolean;
  showMarket?: boolean;
  enableSTT?: boolean;
  hideGitHub?: boolean;
  hideDocs?: boolean;
  showTokenUsage?: boolean;
  showApiPage?: boolean;
  showRecharge?: boolean;
}
```

**返回示例（节选）**:

- `descriptionLink`: `null` 或字符串
- `serverConfig.aiProvider.openai`: `enabled: true`，`enabledModels: ["gpt-5.2","gpt-5-mini","gpt-5-nano"]`，`serverModelLists` 含各模型定价与能力
- `serverConfig.aiProvider.anthropic` / `google` / `openrouter` 等结构类似
- `serverConfig.oAuthSSOProviders`: `["github","tronlink","bybit","tokenpocket","binance","okx","metamask","trust"]`
- `serverFeatureFlags`: 如 `showCreateSession: true`、`enablePlugins: true`、`showTokenUsage: true` 等

---

### getDefaultAgentConfig

获取服务端默认 Agent 配置（用于新会话/新 Agent 的初始配置）。

**类型**: `query`

**权限**: 公开

**输入参数**: 无

**返回**: 与前端 Agent 配置结构兼容的局部对象（`PartialDeep<LobeAgentConfig>`），可能为空对象 `{}`。

---

## 使用示例

```typescript
// 前端通过 tRPC 客户端
const config = await trpc.config.getGlobalConfig.query();

console.log(config.serverConfig.aiProvider.openai?.enabledModels);
console.log(config.serverFeatureFlags.enablePlugins);

// 或通过封装的 globalService（ainft-chat-opcnclaw）
import { globalService } from '@/services/global';

const config = await globalService.getGlobalConfig();
```

---

## 说明

- **getGlobalConfig** 会在服务端合并环境/Edge 配置与按用户的功能开关，用于控制前端展示（设置页、模型选择、OAuth 登录入口、插件/知识库/充值等）。
- **getDefaultAgentConfig** 与 **getGlobalConfig** 均为 `publicProcedure`，无需登录即可调用；是否展示某些能力由 `serverFeatureFlags` 控制。
- 详细实现与类型定义见 ainft-chat-opcnclaw 源码：`src/server/routers/lambda/config/index.ts`、`packages/types/src/serverConfig.ts`、`src/config/featureFlags/schema.ts`。
