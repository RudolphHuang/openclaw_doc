# user_memories_preferences

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `character varying(255)` | NO |  | PK |  |
| `user_memory_id` | `character varying(255)` | YES |  | FK → user_memories.id |  |
| `conclusion_directives` | `text` | YES |  |  |  |
| `conclusion_directives_vector` | `USER-DEFINED` | YES |  |  |  |
| `type` | `character varying(255)` | YES |  |  |  |
| `suggestions` | `text` | YES |  |  |  |
| `score_priority` | `numeric` | YES | 0 |  |  |
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
| `user_memory_id` | `user_memories` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `user_memories_preferences_conclusion_directives_vector_index` | `CREATE INDEX user_memories_preferences_conclusion_directives_vector_index ON public.user_memories_preferences USING hnsw (conclusion_directives_vector vector_cosine_ops)` |
