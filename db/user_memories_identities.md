# user_memories_identities

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `description` | `text` | YES |  |  |  |
| `description_vector` | `USER-DEFINED` | YES |  |  |  |
| `id` | `character varying(255)` | NO |  | PK |  |
| `relationship` | `character varying(255)` | YES |  |  |  |
| `role` | `text` | YES |  |  |  |
| `type` | `character varying(255)` | YES |  |  |  |
| `user_memory_id` | `character varying(255)` | YES |  | FK → user_memories.id |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `user_id` | `text` | YES |  | FK → users.id |  |
| `metadata` | `jsonb` | YES |  |  |  |
| `tags` | `ARRAY` | YES |  |  |  |
| `episodic_date` | `timestamp with time zone` | YES |  |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |
| `user_memory_id` | `user_memories` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `user_memories_identities_description_vector_index` | `CREATE INDEX user_memories_identities_description_vector_index ON public.user_memories_identities USING hnsw (description_vector vector_cosine_ops)` |
| `user_memories_identities_type_index` | `CREATE INDEX user_memories_identities_type_index ON public.user_memories_identities USING btree (type)` |
