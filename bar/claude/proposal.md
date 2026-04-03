## Why

当前的记忆系统依赖向量嵌入（pgvector）进行语义搜索，这带来了显著的问题：嵌入向量对用户不可读、不可编辑；依赖嵌入模型生成向量；5 张关联表结构复杂；向量相似度并不总能准确反映对话相关性。

我们需要一个更简洁、更透明的记忆架构：记忆以可读的 Markdown 文本存储，由 LLM 自身判断相关性（而非向量相似度计算），用户可以像编辑文档一样直接查看和编辑所有记忆内容。

核心理念：**记忆是文本，不是向量。判断相关性的是 AI，不是算法。**

## What Changes

- **新增文本记忆存储**：记忆以结构化 Markdown 条目存储在数据库中，采用索引 + 条目的两层结构
- **AI 驱动的记忆生命周期**：LLM 在对话中自动识别值得记住的信息，通过工具调用创建/更新/删除记忆条目，并根据索引自主判断需要加载哪些记忆详情
- **记忆感知的上下文管道**：新增上下文引擎处理器，将记忆索引（及选择性加载的记忆详情）注入系统提示词
- **聊天界面记忆开关**：在聊天输入区添加切换控件，控制当前对话是否读取记忆、是否写入记忆
- **用户记忆管理页面**：在用户设置中新增记忆管理页面，可浏览、搜索、编辑和删除所有记忆
- **自然语言记忆指令**：用户可通过 "记住这个"/"忘记 X" 等自然语言指令直接管理记忆
- **LLM 记忆工具**：注册一个函数调用工具，供 LLM 调用以创建、更新、查询和删除记忆条目

## Capabilities

### New Capabilities

- `memory-storage`：文本记忆的数据库 Schema 与服务层，包含 Markdown 内容、分类及按用户的索引系统
- `memory-tool`：LLM 函数调用工具，使 AI 在对话中创建、更新、查询和删除记忆条目
- `memory-context-provider`：上下文引擎处理器，将记忆索引加载到系统提示词中，并选择性注入相关记忆详情
- `memory-chat-controls`：聊天输入区的记忆读写开关控件
- `memory-management-page`：用户设置中的记忆管理页面，支持浏览、搜索、编辑和删除

### Modified Capabilities

_（不修改现有能力。现有的向量记忆 `userMemories` 表保持不变——这是一个并行系统，可以共存，未来择机替换旧系统。）_

## Impact

- **数据库**：新增 `text_memories` 和 `text_memory_index` 两张表（Drizzle Schema + 迁移）。不修改现有 `user_memories` 表
- **上下文引擎**（`/packages/context-engine/`）：新增 `MemoryProvider` 处理器加入管道
- **聊天服务**（`/src/services/chat/`）：集成记忆工具的读写能力
- **tRPC 路由**（`/src/server/routers/`）：新增记忆 CRUD 路由
- **聊天界面**（`/src/features/ChatInput/`）：新增记忆开关控件
- **设置界面**（`/src/app/[variants]/(main)/settings/`）：新增记忆管理页面
- **Agent 运行时**（`/packages/agent-runtime/`）：在工具系统中注册记忆工具
- **用户设置类型**（`/packages/types/`）：新增记忆相关的设置字段
