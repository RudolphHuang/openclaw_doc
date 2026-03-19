# topics

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK |  |
| `session_id` | `text` | YES |  | FK → sessions.id |  |
| `user_id` | `text` | NO |  | FK → users.id |  |
| `favorite` | `boolean` | YES | false |  |  |
| `title` | `text` | YES |  |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `client_id` | `text` | YES |  |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `history_summary` | `text` | YES |  |  |  |
| `metadata` | `jsonb` | YES |  |  |  |
| `group_id` | `text` | YES |  | FK → chat_groups.id |  |

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
