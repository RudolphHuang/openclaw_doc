# unstructured_chunks

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `uuid` | NO | gen_random_uuid() | PK |  |
| `text` | `text` | YES |  |  |  |
| `metadata` | `jsonb` | YES |  |  |  |
| `index` | `integer` | YES |  |  |  |
| `type` | `character varying` | YES |  |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `parent_id` | `character varying` | YES |  |  |  |
| `composite_id` | `uuid` | YES |  | FK → chunks.id |  |
| `user_id` | `text` | YES |  | FK → users.id |  |
| `file_id` | `character varying` | YES |  | FK → files.id |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `client_id` | `text` | YES |  |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `composite_id` | `chunks` | `id` |
| `file_id` | `files` | `id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `unstructured_chunks_client_id_user_id_unique` | `CREATE UNIQUE INDEX unstructured_chunks_client_id_user_id_unique ON public.unstructured_chunks USING btree (client_id, user_id)` |
