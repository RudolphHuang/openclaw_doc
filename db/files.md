# files

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK |  |
| `user_id` | `text` | NO |  | FK → users.id |  |
| `file_type` | `character varying(255)` | NO |  |  |  |
| `name` | `text` | NO |  |  |  |
| `size` | `integer` | NO |  |  |  |
| `url` | `text` | NO |  |  |  |
| `metadata` | `jsonb` | YES |  |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `file_hash` | `character varying(64)` | YES |  | FK → global_files.hash_id |  |
| `chunk_task_id` | `uuid` | YES |  | FK → async_tasks.id |  |
| `embedding_task_id` | `uuid` | YES |  | FK → async_tasks.id |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `client_id` | `text` | YES |  |  |  |
| `source` | `text` | YES |  |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `chunk_task_id` | `async_tasks` | `id` |
| `embedding_task_id` | `async_tasks` | `id` |
| `file_hash` | `global_files` | `hash_id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `file_hash_idx` | `CREATE INDEX file_hash_idx ON public.files USING btree (file_hash)` |
| `files_client_id_user_id_unique` | `CREATE UNIQUE INDEX files_client_id_user_id_unique ON public.files USING btree (client_id, user_id)` |
