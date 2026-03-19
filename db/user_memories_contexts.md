# user_memories_contexts

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `character varying(255)` | NO |  | PK |  |
| `user_memory_ids` | `jsonb` | YES |  |  |  |
| `associated_objects` | `jsonb` | YES |  |  |  |
| `associated_subjects` | `jsonb` | YES |  |  |  |
| `title` | `text` | YES |  |  |  |
| `title_vector` | `USER-DEFINED` | YES |  |  |  |
| `description` | `text` | YES |  |  |  |
| `description_vector` | `USER-DEFINED` | YES |  |  |  |
| `type` | `character varying(255)` | YES |  |  |  |
| `current_status` | `text` | YES |  |  |  |
| `score_impact` | `numeric` | YES | 0 |  |  |
| `score_urgency` | `numeric` | YES | 0 |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `user_id` | `text` | YES |  | FK → users.id |  |
| `metadata` | `jsonb` | YES |  |  |  |
| `tags` | `ARRAY` | YES |  |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `user_memories_contexts_description_vector_index` | `CREATE INDEX user_memories_contexts_description_vector_index ON public.user_memories_contexts USING hnsw (description_vector vector_cosine_ops)` |
| `user_memories_contexts_title_vector_index` | `CREATE INDEX user_memories_contexts_title_vector_index ON public.user_memories_contexts USING hnsw (title_vector vector_cosine_ops)` |
| `user_memories_contexts_type_index` | `CREATE INDEX user_memories_contexts_type_index ON public.user_memories_contexts USING btree (type)` |
