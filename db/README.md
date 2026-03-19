# 数据库表模型文档

数据库：`db_ainft_chat_dev`（PostgreSQL + pgvector）

共 **77** 张表，按功能模块分组如下：

## 用户与认证

| 表名 | 说明 |
|------|------|
| [users](./users.md) | 用户主表 |
| [user_settings](./user_settings.md) | 用户个性化设置 |
| [nextauth_accounts](./nextauth_accounts.md) | NextAuth OAuth账号绑定 |
| [nextauth_sessions](./nextauth_sessions.md) | NextAuth会话 |
| [nextauth_authenticators](./nextauth_authenticators.md) | NextAuth WebAuthn认证器 |
| [nextauth_verificationtokens](./nextauth_verificationtokens.md) | NextAuth邮箱验证Token |
| [oauth_handoffs](./oauth_handoffs.md) | OAuth跳转中间态存储 |
| [api_keys](./api_keys.md) | 用户API Key管理 |

## OIDC（OpenID Connect）

| 表名 | 说明 |
|------|------|
| [oidc_clients](./oidc_clients.md) | OIDC客户端注册 |
| [oidc_access_tokens](./oidc_access_tokens.md) | OIDC访问令牌 |
| [oidc_refresh_tokens](./oidc_refresh_tokens.md) | OIDC刷新令牌 |
| [oidc_authorization_codes](./oidc_authorization_codes.md) | OIDC授权码 |
| [oidc_device_codes](./oidc_device_codes.md) | OIDC设备码 |
| [oidc_grants](./oidc_grants.md) | OIDC授权记录 |
| [oidc_sessions](./oidc_sessions.md) | OIDC会话 |
| [oidc_interactions](./oidc_interactions.md) | OIDC交互过程 |
| [oidc_consents](./oidc_consents.md) | OIDC用户授权同意 |

## RBAC 权限控制

| 表名 | 说明 |
|------|------|
| [rbac_roles](./rbac_roles.md) | 角色定义 |
| [rbac_permissions](./rbac_permissions.md) | 权限定义 |
| [rbac_role_permissions](./rbac_role_permissions.md) | 角色-权限关联 |
| [rbac_user_roles](./rbac_user_roles.md) | 用户-角色关联 |

## 聊天核心

| 表名 | 说明 |
|------|------|
| [sessions](./sessions.md) | 聊天会话 |
| [session_groups](./session_groups.md) | 会话分组 |
| [topics](./topics.md) | 会话内话题 |
| [messages](./messages.md) | 消息主表 |
| [message_groups](./message_groups.md) | 消息分组（多Agent并行回复） |
| [threads](./threads.md) | 消息线程 |
| [messages_files](./messages_files.md) | 消息-文件关联 |

## Agent

| 表名 | 说明 |
|------|------|
| [agents](./agents.md) | Agent定义 |
| [agents_to_sessions](./agents_to_sessions.md) | Agent-会话关联 |
| [agents_files](./agents_files.md) | Agent-文件关联 |
| [agents_knowledge_bases](./agents_knowledge_bases.md) | Agent-知识库关联 |
| [chat_groups](./chat_groups.md) | 多Agent聊天组 |
| [chat_groups_agents](./chat_groups_agents.md) | 聊天组-Agent成员 |

## 消息扩展

| 表名 | 说明 |
|------|------|
| [message_plugins](./message_plugins.md) | 消息插件调用记录 |
| [message_translates](./message_translates.md) | 消息翻译 |
| [message_tts](./message_tts.md) | 消息TTS语音 |
| [message_chunks](./message_chunks.md) | 消息-Chunk关联（RAG引用） |
| [message_queries](./message_queries.md) | 消息RAG查询记录 |
| [message_query_chunks](./message_query_chunks.md) | 消息查询-Chunk相似度 |

## 文件与知识库

| 表名 | 说明 |
|------|------|
| [files](./files.md) | 用户上传文件 |
| [global_files](./global_files.md) | 全局文件（按hash去重） |
| [files_to_sessions](./files_to_sessions.md) | 文件-会话关联 |
| [knowledge_bases](./knowledge_bases.md) | 知识库 |
| [knowledge_base_files](./knowledge_base_files.md) | 知识库-文件关联 |

## RAG 向量检索

| 表名 | 说明 |
|------|------|
| [chunks](./chunks.md) | 文本分块 |
| [embeddings](./embeddings.md) | 向量嵌入（pgvector） |
| [file_chunks](./file_chunks.md) | 文件-Chunk关联 |
| [document_chunks](./document_chunks.md) | 文档-Chunk关联 |
| [unstructured_chunks](./unstructured_chunks.md) | 非结构化分块 |
| [documents](./documents.md) | 解析后的文档 |
| [topic_documents](./topic_documents.md) | 话题-文档关联 |

## RAG 评估

| 表名 | 说明 |
|------|------|
| [rag_eval_datasets](./rag_eval_datasets.md) | RAG评估数据集 |
| [rag_eval_dataset_records](./rag_eval_dataset_records.md) | 评估数据集记录 |
| [rag_eval_evaluations](./rag_eval_evaluations.md) | 评估任务 |
| [rag_eval_evaluation_records](./rag_eval_evaluation_records.md) | 评估结果记录 |

## 用户记忆（Memory）

| 表名 | 说明 |
|------|------|
| [user_memories](./user_memories.md) | 用户记忆主表 |
| [user_memories_contexts](./user_memories_contexts.md) | 记忆上下文 |
| [user_memories_experiences](./user_memories_experiences.md) | 记忆经历 |
| [user_memories_identities](./user_memories_identities.md) | 记忆身份信息 |
| [user_memories_preferences](./user_memories_preferences.md) | 记忆偏好 |

## AI 模型与Provider

| 表名 | 说明 |
|------|------|
| [ai_providers](./ai_providers.md) | AI提供商配置 |
| [ai_models](./ai_models.md) | AI模型配置 |

## 图片生成

| 表名 | 说明 |
|------|------|
| [generation_topics](./generation_topics.md) | 图片生成话题 |
| [generation_batches](./generation_batches.md) | 图片生成批次 |
| [generations](./generations.md) | 单张图片生成记录 |

## 异步任务

| 表名 | 说明 |
|------|------|
| [async_tasks](./async_tasks.md) | 异步任务状态 |

## 插件

| 表名 | 说明 |
|------|------|
| [user_installed_plugins](./user_installed_plugins.md) | 用户安装的插件 |

## 积分与支付（t_ 前缀）

| 表名 | 说明 |
|------|------|
| [t_user_points](./t_user_points.md) | 用户积分余额 |
| [t_user_point_flows](./t_user_point_flows.md) | 积分流水 |
| [t_user_wallet](./t_user_wallet.md) | 用户加密货币钱包 |
| [t_recharge_records](./t_recharge_records.md) | 充值记录（链上转账） |
| [t_scan_tasks](./t_scan_tasks.md) | 区块链扫描任务 |
| [t_model_price](./t_model_price.md) | 模型调用单价配置 |
| [t_merchants](./t_merchants.md) | 商户信息 |
| [t_merchant_keys](./t_merchant_keys.md) | 商户密钥 |
| [t_signup_bonus_ip_limits](./t_signup_bonus_ip_limits.md) | 注册奖励IP限流 |

---

> 文档由脚本自动生成，以数据库实际结构为准。更新时间：2026-03-19
