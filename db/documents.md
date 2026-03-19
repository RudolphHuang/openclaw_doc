# documents

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `character varying(30)` | NO |  | PK |  |
| `title` | `text` | YES |  |  |  |
| `content` | `text` | YES |  |  |  |
| `file_type` | `character varying(255)` | NO |  |  |  |
| `filename` | `text` | YES |  |  |  |
| `total_char_count` | `integer` | NO |  |  |  |
| `total_line_count` | `integer` | NO |  |  |  |
| `metadata` | `jsonb` | YES |  |  |  |
| `pages` | `jsonb` | YES |  |  |  |
| `source_type` | `text` | NO |  |  |  |
| `source` | `text` | NO |  |  |  |
| `file_id` | `text` | YES |  | FK → files.id |  |
| `user_id` | `text` | NO |  | FK → users.id |  |
| `client_id` | `text` | YES |  |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `editor_data` | `jsonb` | YES |  |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `file_id` | `files` | `id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `documents_client_id_user_id_unique` | `CREATE UNIQUE INDEX documents_client_id_user_id_unique ON public.documents USING btree (client_id, user_id)` |
| `documents_file_id_idx` | `CREATE INDEX documents_file_id_idx ON public.documents USING btree (file_id)` |
| `documents_file_type_idx` | `CREATE INDEX documents_file_type_idx ON public.documents USING btree (file_type)` |
| `documents_source_idx` | `CREATE INDEX documents_source_idx ON public.documents USING btree (source)` |
