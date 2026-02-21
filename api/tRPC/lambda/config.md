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

---

## getGlobalConfig 返回字段说明

### 一、顶层 GlobalRuntimeConfig

| 字段 | 类型 | 含义 |
|------|------|------|
| `descriptionLink` | `string \| null` | 全局描述/帮助链接，来自环境变量 `DESCRIPTION_LINK`。用于在 UI 中展示「说明」等入口。 |
| `serverConfig` | `GlobalServerConfig` | 服务端全局业务配置，包含 AI 提供商、上传、OAuth、遥测等。详见下文。 |
| `serverFeatureFlags` | `IFeatureFlagsState` | 功能开关状态（已按当前用户评估为布尔值）。用于控制前端各功能入口的显示与隐藏。详见「功能开关字段」表。 |

---

### 二、serverConfig（GlobalServerConfig）字段

| 字段 | 类型 | 含义 |
|------|------|------|
| `aiProvider` | `Record<string, ServerModelProviderConfig>` | 按提供商 ID 聚合的配置。key 如 `openai`、`anthropic`、`google`、`openrouter`、`ollama` 等。每个 value 包含该提供商是否启用、启用哪些模型、服务端模型卡片/列表（含定价与能力）。 |
| `defaultAgent` | `object \| undefined` | 服务端默认 Agent 配置片段，用于新建会话或新建 Agent 时的初始值。可能为空对象 `{}`。 |
| `enableUploadFileToServer` | `boolean \| undefined` | 是否允许用户将文件上传到服务端（而不仅限本地/浏览器）。为 `true` 时前端可展示上传到服务器的选项。 |
| `enabledAccessCode` | `boolean \| undefined` | 是否启用「访问码」校验。为 `true` 时需输入正确访问码才能使用应用。 |
| `enabledOAuthSSO` | `boolean \| undefined` | （已废弃）是否启用 OAuth SSO 登录。实际使用的登录方式以 `oAuthSSOProviders` 为准。 |
| `image` | `object \| undefined` | 图片相关全局配置。如 `defaultImageNum`（默认生成图片数量）等，结构见 `UserImageConfig`。 |
| `languageModel` | `Record<string, ServerModelProviderConfig> \| undefined` | 与 `aiProvider` 结构相同的语言模型配置，部分场景（如设置页）使用该 key。与 `aiProvider` 可能部分重复。 |
| `oAuthSSOProviders` | `string[] \| undefined` | 支持的 OAuth/钱包登录提供商 ID 列表。例如：`["github","tronlink","bybit","tokenpocket","binance","okx","metamask","trust"]`。前端据此展示对应登录按钮。 |
| `systemAgent` | `object \| undefined` | 系统 Agent 配置（如 agentMeta、queryRewrite、topic、translation 等子能力是否启用及使用的 model/provider）。结构见 `UserSystemAgentConfig`。 |
| `telemetry` | `{ langfuse?: boolean }` | 遥测配置。`langfuse` 为 `true` 时表示启用 Langfuse 等遥测上报。 |

---

### 三、aiProvider / languageModel 下单个提供商（ServerModelProviderConfig）字段

| 字段 | 类型 | 含义 |
|------|------|------|
| `enabled` | `boolean \| undefined` | 该提供商是否在服务端启用。为 `false` 或未配置时，前端通常不展示该提供商或置灰。 |
| `enabledModels` | `string[] \| null \| undefined` | 服务端允许使用的模型 ID 列表。例如 OpenAI 下 `["gpt-5.2","gpt-5-mini","gpt-5-nano"]`。前端模型选择器应只展示此列表中的模型（若有）。 |
| `fetchOnClient` | `boolean \| undefined` | 是否由客户端自行拉取模型列表（如 Ollama 本地拉取）。为 `true` 时，服务端可能不返回或仅部分返回 `serverModelLists`。 |
| `serverModelCards` | `Array<ChatModelCard> \| null \| undefined` | 服务端下发的「模型卡片」列表，用于展示与基础能力判断。字段含义见下表「serverModelCards 单条（ChatModelCard）」；不含完整定价时以 `serverModelLists` 为准。 |
| `serverModelLists` | `Array<AiFullModelCard> \| null \| undefined` | 服务端下发的完整模型列表，含定价、上下文长度、能力等。字段含义见下表「serverModelLists 单条」。 |

#### serverModelCards 单条（ChatModelCard）字段含义

| 字段 | 类型 | 含义 |
|------|------|------|
| `id` | `string` | 模型唯一 ID，如 `gpt-5.2`、`claude-opus-4-6`。 |
| `displayName` | `string` | 展示名称，如「GPT-5.2」「Claude Opus 4.6」。 |
| `enabled` | `boolean \| undefined` | 该模型是否默认启用。 |
| `contextWindowTokens` | `number \| undefined` | 上下文窗口长度（token 数）。 |
| `maxOutput` | `number \| undefined` | 最大输出 token 数。 |
| `description` | `string \| undefined` | 模型描述文案。 |
| `descriptionLink` | `string \| undefined` | 描述/文档链接。 |
| `vision` | `boolean \| undefined` | 是否支持视觉（多模态输入）。 |
| `functionCall` | `boolean \| undefined` | 是否支持 function call。 |
| `reasoning` | `boolean \| undefined` | 是否支持推理/思考模式。 |
| `files` | `boolean \| undefined` | 是否支持文件上传。 |
| `pricing` | `object \| undefined` | 计费信息（按 token 等），结构见 model-bank 的 `Pricing`。 |
| `releasedAt` | `string \| undefined` | 发布日期，如 `2025-12-11`。 |
| `isMaintenance` | `boolean \| undefined` | 是否处于维护中。 |
| `legacy` | `boolean \| undefined` | 是否标记为遗留/即将下线。 |

#### serverModelLists 单条（AiFullModelCard）字段含义

在 `serverModelCards` 基础上，完整列表还会包含以下与计费、能力、设置相关的字段：

| 字段 | 类型 | 含义 |
|------|------|------|
| `id` | `string` | 模型唯一 ID。 |
| `displayName` | `string` | 展示名称。 |
| `enabled` | `boolean \| undefined` | 是否启用。 |
| `providerId` | `string \| undefined` | 所属提供商 ID，如 `openai`、`anthropic`。 |
| `source` | `string \| undefined` | 来源，如 `builtin` 表示内置。 |
| `type` | `string \| undefined` | 模型类型，如 `chat`。 |
| `contextWindowTokens` | `number \| undefined` | 上下文窗口 token 数。 |
| `maxOutput` | `number \| undefined` | 最大输出 token 数。 |
| `description` | `string \| undefined` | 模型描述。 |
| `descriptionLink` | `string \| undefined` | 文档链接。 |
| `releasedAt` | `string \| undefined` | 发布日期。 |
| `abilities` | `object \| undefined` | 能力标签，如 `companyLabel`、`flagship`、`vision`、`reasoning` 等，用于 UI 角标或筛选。 |
| `pointPricing` | `object \| undefined` | 积分定价。常见结构：`units: [{ name: "inputPrice", cost: number }, { name: "outputPrice", cost: number }]`，表示输入/输出每百万 token 消耗的积分。 |
| `pricing` | `object \| undefined` | 详细计费单元。含 `units` 数组，每项有 `name`（如 `textInput`、`textOutput`、`textInput_cacheRead`、`textInput_cacheWrite`）、`rate`、`strategy`（如 `fixed`、`tiered`、`lookup`）、`unit`（如 `millionTokens`）；部分有 `tiers` 或 `lookup.prices`。 |
| `settings` | `object \| undefined` | 模型专属设置项。如 `extendParams`（前端需展示的扩展参数名）、`searchImpl`、`searchProvider` 等。 |
| `isMaintenance` | `boolean \| undefined` | 是否维护中。 |

---

### 四、功能开关字段（serverFeatureFlags / IFeatureFlagsState）

所有字段均为 **布尔值**，表示「当前用户/当前请求下该功能是否开启」。未传或未配置时可能为 `undefined`。

| 字段 | 含义 |
|------|------|
| `isAgentEditable` | 是否允许编辑 Agent（创建/修改智能体配置）。 |
| `showCreateSession` | 是否展示「创建会话」入口。 |
| `enableGroupChat` | 是否启用群聊/多角色对话。 |
| `showLLM` | 是否在设置中展示「语言模型」相关配置。 |
| `showProvider` | 是否在设置中展示「提供商」相关配置。 |
| `showPinList` | 是否展示置顶会话列表。 |
| `showOpenAIApiKey` | 是否在设置中展示 OpenAI API Key 配置项。 |
| `showOpenAIProxyUrl` | 是否在设置中展示 OpenAI 代理地址配置项。 |
| `showApiKeyManage` | 是否展示「API Key 管理」入口（如统一密钥管理页）。 |
| `enablePlugins` | 是否启用插件能力。 |
| `showDalle` | 是否展示 Dalle 相关图像生成入口。 |
| `showAiImage` | 是否展示 AI 图像生成入口。 |
| `showChangelog` | 是否展示更新日志入口。 |
| `enableCheckUpdates` | 是否启用检查更新。 |
| `showWelcomeSuggest` | 是否在欢迎页/空状态展示推荐建议。 |
| `enableClerkSignUp` | 是否允许通过 Clerk 注册（邮箱等）。 |
| `enableKnowledgeBase` | 是否启用知识库功能。 |
| `enableRAGEval` | 是否启用 RAG 评估功能。 |
| `showCloudPromotion` | 是否展示云服务/推广相关入口。 |
| `showMarket` | 是否展示市场（Agent/插件市场）入口。 |
| `enableSTT` | 是否启用语音转文字（STT）。 |
| `hideGitHub` | 是否隐藏 GitHub 相关链接（商业授权场景）。 |
| `hideDocs` | 是否隐藏文档链接（商业授权场景）。 |
| `showTokenUsage` | 是否展示 token 使用量统计。 |
| `showApiPage` | 是否展示 API 使用/配置页。 |
| `showRecharge` | 是否展示充值/积分充值入口。 |

---

## 返回数据结构（TypeScript 汇总）

```typescript
interface GlobalRuntimeConfig {
  descriptionLink?: string | null;
  serverConfig: GlobalServerConfig;
  serverFeatureFlags: IFeatureFlagsState;
}

interface GlobalServerConfig {
  aiProvider: Record<string, ServerModelProviderConfig>;
  defaultAgent?: Record<string, unknown>;
  enableUploadFileToServer?: boolean;
  enabledAccessCode?: boolean;
  enabledOAuthSSO?: boolean;
  image?: { defaultImageNum?: number };
  languageModel?: Record<string, ServerModelProviderConfig>;
  oAuthSSOProviders?: string[];
  systemAgent?: Record<string, unknown>;
  telemetry: { langfuse?: boolean };
}

interface ServerModelProviderConfig {
  enabled?: boolean;
  enabledModels?: string[] | null;
  fetchOnClient?: boolean;
  serverModelCards?: ChatModelCard[] | null;
  serverModelLists?: AiFullModelCard[] | null;
}

// ChatModelCard / AiFullModelCard 的字段见上表，此处略。
```

---

## getDefaultAgentConfig

获取服务端默认 Agent 配置（用于新会话/新 Agent 的初始配置）。

**类型**: `query`

**权限**: 公开

**输入参数**: 无

**返回**: 与前端 Agent 配置结构兼容的局部对象（`PartialDeep<LobeAgentConfig>`），可能为空对象 `{}`。字段含义与前端「默认 Agent 设置」一致，此处不重复列出。

---

## 使用示例

```typescript
// 前端通过 tRPC 客户端
const config = await trpc.config.getGlobalConfig.query();

// 根据功能开关控制 UI
if (config.serverFeatureFlags.enablePlugins) {
  // 展示插件入口
}
if (config.serverFeatureFlags.showRecharge) {
  // 展示充值入口
}

// 读取提供商与模型
const openai = config.serverConfig.aiProvider.openai;
const modelIds = openai?.enabledModels ?? [];
const modelList = openai?.serverModelLists ?? [];

// 或通过封装的 globalService（ainft-chat-opcnclaw）
import { globalService } from '@/services/global';
const config = await globalService.getGlobalConfig();
```

---

## 说明

- **getGlobalConfig** 在服务端合并环境/Edge 配置与按用户的功能开关，前端应据此控制设置页、模型选择、OAuth 登录入口、插件/知识库/充值等展示。
- **getDefaultAgentConfig** 与 **getGlobalConfig** 均为 `publicProcedure`，无需登录即可调用。
- 详细实现与类型定义见 ainft-chat-opcnclaw 源码：`src/server/routers/lambda/config/index.ts`、`packages/types/src/serverConfig.ts`、`src/config/featureFlags/schema.ts`、`packages/types/src/llm.ts`。
