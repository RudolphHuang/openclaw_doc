# LobeChat API 接口文档

本文档提供 LobeChat 后端 API 的详细说明，供前端开发人员使用。

## API 架构概述

LobeChat 后端提供两种 API 形式：

### 1. RESTful WebAPI (`src/app/(backend)/webapi/`)

处理需要特殊处理的端点，如流式响应、TTS、文件服务等。

### 2. tRPC Routers (`src/server/routers/`)

类型安全的主要业务路由，按运行时分组：

- **lambda/** — 主业务路由（agent、session、message、topic、file、knowledge、settings 等）
- **async/** — 耗时异步操作（文件处理、图像生成、RAG 评估）
- **tools/** — 工具调用（search、MCP、market）
- **mobile/** — 移动端专用
- **edge/** — Edge Runtime 路由
- **desktop/** — 桌面端专用

---

## RESTful WebAPI 接口

### 认证相关
- [认证方式概览](RESTful/auth-overview.md) - 选择合适的认证方式（**推荐先阅读**）
- [Clerk 认证](RESTful/auth-clerk.md) - 邮箱、手机号、OAuth 登录（含邮箱+密码、魔法链接）
- [Google OAuth 登录](RESTful/auth-google.md) - Google 账号第三方登录
- [TronLink 登录](RESTful/auth-tronlink.md) - TronLink 钱包登录接口
- [Apple 登录说明](RESTful/auth-apple-notice.md) - Apple 登录当前状态和实现指南

### 聊天相关
- [POST /webapi/chat/:provider](RESTful/chat.md) - AI 聊天流式响应

### 语音相关
- [POST /webapi/tts/edge](RESTful/tts-edge.md) - Edge TTS 语音合成
- [POST /webapi/tts/microsoft](RESTful/tts-microsoft.md) - Microsoft TTS 语音合成
- [POST /webapi/tts/openai](RESTful/tts-openai.md) - OpenAI TTS 语音合成
- [POST /webapi/stt/openai](RESTful/stt-openai.md) - OpenAI 语音转文字

### 图像生成
- [POST /webapi/text-to-image/:provider](RESTful/text-to-image.md) - 文本生成图像
- [POST /webapi/create-image/comfyui](RESTful/create-image-comfyui.md) - ComfyUI 图像生成

### 模型相关
- [GET /webapi/models/:provider](RESTful/models.md) - 获取模型列表
- [POST /webapi/models/:provider/pull](RESTful/models-pull.md) - 拉取模型

### 用户与文件
- [GET /webapi/user/avatar/:id/:image](RESTful/user-avatar.md) - 获取用户头像

### 工具相关
- [POST /webapi/plugin/gateway](RESTful/plugin-gateway.md) - 插件网关

### 系统相关
- [POST /webapi/trace](RESTful/trace.md) - 上报追踪数据
- [POST /webapi/proxy](RESTful/proxy.md) - 代理请求
- [POST /webapi/tokenizer](RESTful/tokenizer.md) - 令牌计数
- [POST /webapi/revalidate](RESTful/revalidate.md) - 重新验证缓存

---

## tRPC Lambda 接口（主业务）

### 用户管理
- [user.*](tRPC/lambda/user.md) - 用户信息管理、设置、偏好、SSO、积分奖励

### 会话管理
- [session.*](tRPC/lambda/session.md) - 会话的创建、查询、更新、删除、克隆、搜索
- [sessionGroup.*](tRPC/lambda/sessionGroup.md) - 会话分组管理

### 消息管理
- [message.*](tRPC/lambda/message.md) - 消息的CRUD、翻译、TTS、插件状态、元数据

### 主题（Topic）管理
- [topic.*](tRPC/lambda/topic.md) - 话题的创建、查询、更新、删除、克隆、搜索

### Agent 管理
- [agent.*](tRPC/lambda/agent.md) - Agent 配置、知识库绑定、文件绑定

### 群组（Group）管理
- [group.*](tRPC/lambda/group.md) - 群组聊天管理、成员管理

### 线程（Thread）管理
- [thread.*](tRPC/lambda/thread.md) - 线程管理

### 文件管理
- [file.*](tRPC/lambda/file.md) - 文件上传、查询、删除、哈希校验
- [upload.*](tRPC/lambda/upload.md) - 文件上传相关

### 知识库管理
- [knowledgeBase.*](tRPC/lambda/knowledgeBase.md) - 知识库CRUD、文件管理
- [chunk.*](tRPC/lambda/chunk.md) - 文本块管理、向量检索
- [document.*](tRPC/lambda/document.md) - 文档管理

### AI 模型与提供商
- [aiModel.*](tRPC/lambda/aiModel.md) - AI 模型管理
- [aiProvider.*](tRPC/lambda/aiProvider.md) - AI 提供商管理
- [aiChat.*](tRPC/lambda/aiChat.md) - AI 聊天配置

### 图像生成
- [image.*](tRPC/lambda/image.md) - 图像生成任务
- [generation.*](tRPC/lambda/generation.md) - 生成任务管理
- [generationBatch.*](tRPC/lambda/generationBatch.md) - 批量生成任务
- [generationTopic.*](tRPC/lambda/generationTopic.md) - 生成任务主题
- [comfyui.*](tRPC/lambda/comfyui.md) - ComfyUI 工作流管理

### 插件与市场
- [plugin.*](tRPC/lambda/plugin.md) - 插件管理
- [market.*](tRPC/lambda/market.md) - 市场（Agent、插件）

### 数据导入导出
- [importer.*](tRPC/lambda/importer.md) - 数据导入
- [exporter.*](tRPC/lambda/exporter.md) - 数据导出

### 系统配置
- [config.*](tRPC/lambda/config.md) - 系统配置
- [basicConfig.*](tRPC/lambda/basicConfig.md) - 基础配置

### API Key 管理
- [apiKey.*](tRPC/lambda/apiKey.md) - API Key 管理

### RAG 评估
- [ragEval.*](tRPC/lambda/ragEval.md) - RAG 效果评估

### 使用统计与订单
- [usage.*](tRPC/lambda/usage.md) - 使用统计
- [order.*](tRPC/lambda/order.md) - 订单管理

### 充值与支付
- [TRON 充值](payment/tron-recharge.md) - TRON 区块链充值（当前系统）
- [Apple 支付技术方案](payment/apple-pay-technical-plan.md) - Apple Pay/IAP 实现方案

---

## tRPC Async 接口（异步任务）

- [async.file.*](tRPC/async/file.md) - 文件分块、向量嵌入
- [async.image.*](tRPC/async/image.md) - 图像异步生成
- [async.ragEval.*](tRPC/async/ragEval.md) - RAG 异步评估

---

## tRPC Tools 接口（工具调用）

- [tools.search.*](tRPC/tools/search.md) - 搜索工具
- [tools.mcp.*](tRPC/tools/mcp.md) - MCP (Model Context Protocol) 工具

---

## tRPC Mobile 接口（移动端）

移动端使用 Lambda 路由的子集，详见：

- [mobile.*](tRPC/mobile/index.md) - 移动端接口列表

---

## tRPC Edge 接口

- [edge.appStatus.*](tRPC/edge/appStatus.md) - 应用状态检查
- [edge.upload.*](tRPC/edge/upload.md) - Edge 上传

---

## tRPC Desktop 接口（桌面端）

- [desktop.pgTable.*](tRPC/desktop/pgTable.md) - PGLite 表管理
- [desktop.mcp.*](tRPC/desktop/mcp.md) - 桌面端 MCP

---

## 通用说明

### tRPC 调用方式

tRPC 接口通过 `/trpc` 端点访问，分为：

- **Query（查询）**: 用于读取数据
- **Mutation（变更）**: 用于写入、更新、删除数据

前端通过 tRPC 客户端调用：

```typescript
// 查询示例
const sessions = await trpc.session.getSessions.query({ current: 1, pageSize: 20 });

// 变更示例
const sessionId = await trpc.session.createSession.mutate({
  session: { title: 'New Chat' },
  config: {},
  type: 'agent'
});
```

### 认证

- **authedProcedure**: 需要用户认证（JWT）
- **publicProcedure**: 公开访问
- **asyncAuthedProcedure**: 异步任务需要认证

### 类型安全

所有 tRPC 接口都是类型安全的，TypeScript 会自动推导输入和输出类型。

---

## 快速导航

### 核心功能
- [用户管理](tRPC/lambda/user.md)
- [会话管理](tRPC/lambda/session.md)
- [消息管理](tRPC/lambda/message.md)
- [Agent 管理](tRPC/lambda/agent.md)

### 高级功能
- [知识库管理](tRPC/lambda/knowledgeBase.md)
- [文件管理](tRPC/lambda/file.md)
- [图像生成](tRPC/lambda/generation.md)
- [插件管理](tRPC/lambda/plugin.md)

### 开发者工具
- [数据导入导出](tRPC/lambda/importer.md)
- [RAG 评估](tRPC/lambda/ragEval.md)
- [使用统计](tRPC/lambda/usage.md)

---

## 更新日志

- 2026-02-14: 初始版本创建
