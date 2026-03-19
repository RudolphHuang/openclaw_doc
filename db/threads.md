# threads

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK |  |
| `title` | `text` | YES |  |  |  |
| `type` | `text` | NO |  |  |  |
| `status` | `text` | YES | 'active'::text |  |  |
| `topic_id` | `text` | NO |  | FK → topics.id |  |
| `source_message_id` | `text` | NO |  |  |  |
| `parent_thread_id` | `text` | YES |  | FK → threads.id |  |
| `user_id` | `text` | NO |  | FK → users.id |  |
| `last_active_at` | `timestamp with time zone` | YES | now() |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `client_id` | `text` | YES |  |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `parent_thread_id` | `threads` | `id` |
| `topic_id` | `topics` | `id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `threads_client_id_user_id_unique` | `CREATE UNIQUE INDEX threads_client_id_user_id_unique ON public.threads USING btree (client_id, user_id)` |
