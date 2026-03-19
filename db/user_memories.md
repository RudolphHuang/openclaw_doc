# user_memories

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `character varying(255)` | NO |  | PK |  |
| `user_id` | `text` | YES |  | FK → users.id |  |
| `memory_category` | `character varying(255)` | YES |  |  |  |
| `memory_layer` | `character varying(255)` | YES |  |  |  |
| `memory_type` | `character varying(255)` | YES |  |  |  |
| `title` | `character varying(255)` | YES |  |  |  |
| `summary` | `text` | YES |  |  |  |
| `summary_vector_1024` | `USER-DEFINED` | YES |  |  |  |
| `details` | `text` | YES |  |  |  |
| `details_vector_1024` | `USER-DEFINED` | YES |  |  |  |
| `status` | `character varying(255)` | YES |  |  |  |
| `accessed_count` | `bigint` | YES | 0 |  |  |
| `last_accessed_at` | `timestamp with time zone` | NO |  |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `metadata` | `jsonb` | YES |  |  |  |
| `tags` | `ARRAY` | YES |  |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `user_memories_details_vector_1024_index` | `CREATE INDEX user_memories_details_vector_1024_index ON public.user_memories USING hnsw (details_vector_1024 vector_cosine_ops)` |
| `user_memories_summary_vector_1024_index` | `CREATE INDEX user_memories_summary_vector_1024_index ON public.user_memories USING hnsw (summary_vector_1024 vector_cosine_ops)` |
