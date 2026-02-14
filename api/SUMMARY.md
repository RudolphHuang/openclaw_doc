# API 文档总结

本文档总结了已创建的 API 接口文档。

## 文档完成状态

### ✅ 已完成的详细文档

以下接口文档包含完整的接口说明、参数、示例和最佳实践：

#### tRPC Lambda 接口（主业务）

- ✅ [user.md](tRPC/lambda/user.md) - 用户管理（包含积分奖励）
- ✅ [session.md](tRPC/lambda/session.md) - 会话管理
- ✅ [message.md](tRPC/lambda/message.md) - 消息管理（包含翻译、TTS、插件等）
- ✅ [topic.md](tRPC/lambda/topic.md) - 主题管理
- ✅ [agent.md](tRPC/lambda/agent.md) - Agent 配置管理
- ✅ [knowledgeBase.md](tRPC/lambda/knowledgeBase.md) - 知识库管理
- ✅ [file.md](tRPC/lambda/file.md) - 文件管理

#### tRPC Async 接口（异步任务）

- ✅ [async/file.md](tRPC/async/file.md) - 文件异步处理（分块、嵌入）

#### tRPC Tools 接口（工具）

- ✅ [tools/search.md](tRPC/tools/search.md) - 搜索工具

#### RESTful WebAPI 接口

- ✅ [RESTful/chat.md](RESTful/chat.md) - AI 聊天流式响应

### 📝 已创建的简要文档

以下接口文档提供了基本说明和使用示例：

#### tRPC Lambda 接口

- 📝 [chunk.md](tRPC/lambda/chunk.md) - 文本块管理
- 📝 [group.md](tRPC/lambda/group.md) - 群组聊天
- 📝 [sessionGroup.md](tRPC/lambda/sessionGroup.md) - 会话分组
- 📝 [thread.md](tRPC/lambda/thread.md) - 线程管理
- 📝 [aiModel.md](tRPC/lambda/aiModel.md) - AI 模型管理
- 📝 [aiProvider.md](tRPC/lambda/aiProvider.md) - AI 提供商管理
- 📝 [market.md](tRPC/lambda/market.md) - 市场（Agent、插件）
- 📝 [plugin.md](tRPC/lambda/plugin.md) - 插件管理
- 📝 [importer.md](tRPC/lambda/importer.md) - 数据导入
- 📝 [exporter.md](tRPC/lambda/exporter.md) - 数据导出
- 📝 [usage.md](tRPC/lambda/usage.md) - 使用统计
- 📝 [generation.md](tRPC/lambda/generation.md) - 图像生成
- 📝 [document.md](tRPC/lambda/document.md) - 文档管理
- 📝 [upload.md](tRPC/lambda/upload.md) - 上传管理
- 📝 [config.md](tRPC/lambda/config.md) - 配置管理
- 📝 [basicConfig.md](tRPC/lambda/basicConfig.md) - 基础配置

#### tRPC Mobile 接口

- 📝 [mobile/index.md](tRPC/mobile/index.md) - 移动端接口说明

#### RESTful WebAPI 接口

- ✅ [RESTful/auth-overview.md](RESTful/auth-overview.md) - 认证方式概览
- ✅ [RESTful/auth-clerk.md](RESTful/auth-clerk.md) - Clerk 认证（邮箱登录）
- ✅ [RESTful/auth-tronlink.md](RESTful/auth-tronlink.md) - TronLink 登录
- 📝 [RESTful/tts-openai.md](RESTful/tts-openai.md) - OpenAI TTS
- 📝 [RESTful/stt-openai.md](RESTful/stt-openai.md) - OpenAI STT
- 📝 [RESTful/tokenizer.md](RESTful/tokenizer.md) - 令牌计数
- 📝 [RESTful/trace.md](RESTful/trace.md) - 追踪上报

### ⚠️ 待完善的文档

以下接口文档尚未创建，可参考源代码：

#### tRPC Lambda 接口

- ⚠️ aiChat - AI 聊天配置
- ⚠️ apiKey - API Key 管理
- ⚠️ comfyui - ComfyUI 工作流
- ⚠️ generationBatch - 批量生成
- ⚠️ generationTopic - 生成主题
- ⚠️ image - 图像管理
- ⚠️ order - 订单管理
- ⚠️ ragEval - RAG 评估

#### tRPC Async 接口

- ⚠️ async/image - 图像异步生成
- ⚠️ async/ragEval - RAG 异步评估

#### tRPC Tools 接口

- ⚠️ tools/mcp - MCP 工具

#### tRPC Edge 接口

- ⚠️ edge/appStatus - 应用状态
- ⚠️ edge/upload - Edge 上传

#### tRPC Desktop 接口

- ⚠️ desktop/pgTable - PGLite 表管理
- ⚠️ desktop/mcp - 桌面端 MCP

#### RESTful WebAPI 接口

- ⚠️ tts/edge - Edge TTS
- ⚠️ tts/microsoft - Microsoft TTS
- ⚠️ text-to-image - 文本生成图像
- ⚠️ create-image/comfyui - ComfyUI 图像生成
- ⚠️ models - 模型列表
- ⚠️ models/pull - 拉取模型
- ⚠️ user/avatar - 用户头像
- ⚠️ plugin/gateway - 插件网关
- ⚠️ proxy - 代理请求
- ⚠️ revalidate - 缓存重验证

---

## 如何使用本文档

### 查找接口

1. 参考 [README.md](README.md) 的目录结构
2. 根据功能模块找到对应文档
3. 详细文档（✅）包含完整说明，简要文档（📝）提供快速参考

### 补充文档

待完善的接口（⚠️）可以通过以下方式了解：

1. 查看源代码：`src/server/routers/` 或 `src/app/(backend)/webapi/`
2. 参考已完成的文档格式
3. 查看测试文件：`**/__tests__/`

### 文档模板

#### 详细文档模板

```markdown
# [接口名称]

[简要描述]

## 接口列表

### [方法名]

[描述]

**类型**: `query` | `mutation`

**权限**: [认证要求]

**输入参数**:

[TypeScript 类型定义]

**返回数据**:

[TypeScript 类型定义]

**说明**: [额外说明]

---

## 使用示例

[代码示例]

## 数据类型

[类型定义]

## 最佳实践

[最佳实践建议]
```

---

## 统计信息

- **总接口数**: 约 80+
- **已完成详细文档**: 12 个（15%）
- **已创建简要文档**: 23 个（29%）
- **待补充文档**: 47 个（58.5%）

---

## 下一步工作

### 优先级 1（核心功能）

- [ ] aiChat - AI 聊天配置
- [ ] apiKey - API Key 管理
- [ ] ragEval - RAG 评估
- [ ] tools/mcp - MCP 工具

### 优先级 2（常用功能）

- [ ] comfyui - ComfyUI 工作流
- [ ] generationBatch - 批量生成
- [ ] image - 图像管理
- [ ] order - 订单管理

### 优先级 3（辅助功能）

- [ ] RESTful WebAPI 剩余接口
- [ ] tRPC Edge 接口
- [ ] tRPC Desktop 接口

---

## 贡献指南

欢迎贡献文档！请遵循以下步骤：

1. 选择一个待完善的接口
2. 参考源代码和已有文档
3. 编写详细的接口文档
4. 提交 PR

---

## 相关资源

- [项目规则文档](.cursor/rules/)
- [测试指南](.cursor/rules/testing-guide/)
- [代码风格指南](.cursor/rules/typescript.mdc)

---

最后更新: 2026-02-14
