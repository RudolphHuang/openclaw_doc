# message_queries

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `uuid` | NO | gen_random_uuid() | PK |  |
| `message_id` | `text` | NO |  | FK → messages.id |  |
| `rewrite_query` | `text` | YES |  |  |  |
| `user_query` | `text` | YES |  |  |  |
| `embeddings_id` | `uuid` | YES |  | FK → embeddings.id |  |
| `user_id` | `text` | NO |  | FK → users.id |  |
| `client_id` | `text` | YES |  |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `embeddings_id` | `embeddings` | `id` |
| `message_id` | `messages` | `id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `message_queries_client_id_user_id_unique` | `CREATE UNIQUE INDEX message_queries_client_id_user_id_unique ON public.message_queries USING btree (client_id, user_id)` |
