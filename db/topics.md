# topics

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK | 话题ID，格式 `tpc_xxx` |
| `session_id` | `text` | YES |  | FK → sessions.id | 所属会话ID |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `favorite` | `boolean` | YES | false |  | 是否收藏该话题 |
| `title` | `text` | YES |  |  | 话题标题（对话主题） |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `client_id` | `text` | YES |  |  | 客户端本地ID |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `history_summary` | `text` | YES |  |  | 历史对话摘要（长对话压缩后的摘要） |
| `metadata` | `jsonb` | YES |  |  | 话题元数据（ChatTopicMetadata类型），JSON |
| `group_id` | `text` | YES |  | FK → chat_groups.id | 所属多Agent聊天组ID |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `group_id` | `chat_groups` | `id` |
| `session_id` | `sessions` | `id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `topics_client_id_user_id_unique` | `CREATE UNIQUE INDEX topics_client_id_user_id_unique ON public.topics USING btree (client_id, user_id)` |
| `topics_id_user_id_idx` | `CREATE INDEX topics_id_user_id_idx ON public.topics USING btree (id, user_id)` |
| `topics_user_id_idx` | `CREATE INDEX topics_user_id_idx ON public.topics USING btree (user_id)` |
