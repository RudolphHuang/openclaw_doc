# messages

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK |  |
| `role` | `character varying(255)` | NO |  |  |  |
| `content` | `text` | YES |  |  |  |
| `model` | `text` | YES |  |  |  |
| `provider` | `text` | YES |  |  |  |
| `favorite` | `boolean` | YES | false |  |  |
| `error` | `jsonb` | YES |  |  |  |
| `tools` | `jsonb` | YES |  |  |  |
| `trace_id` | `text` | YES |  |  |  |
| `observation_id` | `text` | YES |  |  |  |
| `user_id` | `text` | NO |  | FK → users.id |  |
| `session_id` | `text` | YES |  | FK → sessions.id |  |
| `topic_id` | `text` | YES |  | FK → topics.id |  |
| `parent_id` | `text` | YES |  | FK → messages.id |  |
| `quota_id` | `text` | YES |  | FK → messages.id |  |
| `agent_id` | `text` | YES |  | FK → agents.id |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `client_id` | `text` | YES |  |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `thread_id` | `text` | YES |  | FK → threads.id |  |
| `reasoning` | `jsonb` | YES |  |  |  |
| `search` | `jsonb` | YES |  |  |  |
| `metadata` | `jsonb` | YES |  |  |  |
| `group_id` | `text` | YES |  | FK → chat_groups.id |  |
| `target_id` | `text` | YES |  |  |  |
| `message_group_id` | `character varying(255)` | YES |  | FK → message_groups.id |  |
| `source_type` | `character varying(32)` | YES |  |  |  |

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
