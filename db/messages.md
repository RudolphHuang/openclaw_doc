# messages

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK | 消息ID，格式 `msg_xxx` |
| `role` | `character varying(255)` | NO |  |  | 消息角色：`user`/`assistant`/`system`/`tool` |
| `content` | `text` | YES |  |  | 消息文本内容 |
| `model` | `text` | YES |  |  | 生成该消息使用的模型ID |
| `provider` | `text` | YES |  |  | 生成该消息使用的提供商ID |
| `favorite` | `boolean` | YES | false |  | 是否收藏该消息 |
| `error` | `jsonb` | YES |  |  | 消息生成错误信息，JSON |
| `tools` | `jsonb` | YES |  |  | 工具调用列表，JSON |
| `trace_id` | `text` | YES |  |  | Langfuse追踪ID（可观测性） |
| `observation_id` | `text` | YES |  |  | Langfuse观测ID |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `session_id` | `text` | YES |  | FK → sessions.id | 所属会话ID |
| `topic_id` | `text` | YES |  | FK → topics.id | 所属话题ID |
| `parent_id` | `text` | YES |  | FK → messages.id | 父消息ID（消息树结构，编辑/分支） |
| `quota_id` | `text` | YES |  | FK → messages.id | 引用的消息ID（消息引用功能） |
| `agent_id` | `text` | YES |  | FK → agents.id | 生成该消息的Agent ID（群聊场景） |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `client_id` | `text` | YES |  |  | 客户端本地ID，用于多端同步 |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `thread_id` | `text` | YES |  | FK → threads.id | 所属线程ID |
| `reasoning` | `jsonb` | YES |  |  | 模型推理过程（ModelReasoning类型，CoT思考链），JSON |
| `search` | `jsonb` | YES |  |  | 网络搜索结果（GroundingSearch类型），JSON |
| `metadata` | `jsonb` | YES |  |  | 消息扩展元数据，JSON |
| `group_id` | `text` | YES |  | FK → chat_groups.id | 所属聊天组ID（多Agent群聊） |
| `target_id` | `text` | YES |  |  | 消息目标ID（Agent ID、"user"或null，群聊@功能） |
| `message_group_id` | `character varying(255)` | YES |  | FK → message_groups.id | 所属消息组ID（多模型并行回复） |
| `source_type` | `character varying(32)` | YES |  |  | 消息来源类型（32字符） |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `agent_id` | `agents` | `id` |
| `group_id` | `chat_groups` | `id` |
| `message_group_id` | `message_groups` | `id` |
| `parent_id` | `messages` | `id` |
| `quota_id` | `messages` | `id` |
| `session_id` | `sessions` | `id` |
| `thread_id` | `threads` | `id` |
| `topic_id` | `topics` | `id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `message_client_id_user_unique` | `CREATE UNIQUE INDEX message_client_id_user_unique ON public.messages USING btree (client_id, user_id)` |
| `messages_created_at_idx` | `CREATE INDEX messages_created_at_idx ON public.messages USING btree (created_at)` |
| `messages_parent_id_idx` | `CREATE INDEX messages_parent_id_idx ON public.messages USING btree (parent_id)` |
| `messages_quota_id_idx` | `CREATE INDEX messages_quota_id_idx ON public.messages USING btree (quota_id)` |
| `messages_session_id_idx` | `CREATE INDEX messages_session_id_idx ON public.messages USING btree (session_id)` |
| `messages_thread_id_idx` | `CREATE INDEX messages_thread_id_idx ON public.messages USING btree (thread_id)` |
| `messages_topic_id_idx` | `CREATE INDEX messages_topic_id_idx ON public.messages USING btree (topic_id)` |
| `messages_user_id_idx` | `CREATE INDEX messages_user_id_idx ON public.messages USING btree (user_id)` |
