# embeddings

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `uuid` | NO | gen_random_uuid() | PK |  |
| `chunk_id` | `uuid` | YES |  | UQ, FK → chunks.id |  |
| `embeddings` | `USER-DEFINED` | YES |  |  |  |
| `model` | `text` | YES |  |  |  |
| `user_id` | `text` | YES |  | FK → users.id |  |
| `client_id` | `text` | YES |  |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `chunk_id` | `chunks` | `id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `embeddings_chunk_id_idx` | `CREATE INDEX embeddings_chunk_id_idx ON public.embeddings USING btree (chunk_id)` |
| `embeddings_chunk_id_unique` | `CREATE UNIQUE INDEX embeddings_chunk_id_unique ON public.embeddings USING btree (chunk_id)` |
| `embeddings_client_id_user_id_unique` | `CREATE UNIQUE INDEX embeddings_client_id_user_id_unique ON public.embeddings USING btree (client_id, user_id)` |
