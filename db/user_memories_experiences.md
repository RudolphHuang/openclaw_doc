# user_memories_experiences

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `character varying(255)` | NO |  | PK |  |
| `user_memory_id` | `character varying(255)` | YES |  | FK → user_memories.id |  |
| `type` | `character varying(255)` | YES |  |  |  |
| `situation` | `text` | YES |  |  |  |
| `situation_vector` | `USER-DEFINED` | YES |  |  |  |
| `reasoning` | `text` | YES |  |  |  |
| `possible_outcome` | `text` | YES |  |  |  |
| `action` | `text` | YES |  |  |  |
| `action_vector` | `USER-DEFINED` | YES |  |  |  |
| `key_learning` | `text` | YES |  |  |  |
| `key_learning_vector` | `USER-DEFINED` | YES |  |  |  |
| `metadata` | `jsonb` | YES |  |  |  |
| `score_confidence` | `real` | YES | 0 |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `user_id` | `text` | YES |  | FK → users.id |  |
| `tags` | `ARRAY` | YES |  |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |
| `user_memory_id` | `user_memories` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `user_memories_experiences_action_vector_index` | `CREATE INDEX user_memories_experiences_action_vector_index ON public.user_memories_experiences USING hnsw (action_vector vector_cosine_ops)` |
| `user_memories_experiences_key_learning_vector_index` | `CREATE INDEX user_memories_experiences_key_learning_vector_index ON public.user_memories_experiences USING hnsw (key_learning_vector vector_cosine_ops)` |
| `user_memories_experiences_situation_vector_index` | `CREATE INDEX user_memories_experiences_situation_vector_index ON public.user_memories_experiences USING hnsw (situation_vector vector_cosine_ops)` |
| `user_memories_experiences_type_index` | `CREATE INDEX user_memories_experiences_type_index ON public.user_memories_experiences USING btree (type)` |
