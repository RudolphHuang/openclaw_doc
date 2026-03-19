# user_memories_preferences

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `character varying(255)` | NO |  | PK | 偏好记忆ID |
| `user_memory_id` | `character varying(255)` | YES |  | FK → user_memories.id | 关联的主记忆ID |
| `conclusion_directives` | `text` | YES |  |  | 结论性指令/建议内容 |
| `conclusion_directives_vector` | `USER-DEFINED` | YES |  |  | 指令内容的1024维向量（HNSW索引） |
| `type` | `character varying(255)` | YES |  |  | 偏好类型 |
| `suggestions` | `text` | YES |  |  | 相关建议文本 |
| `score_priority` | `numeric` | YES | 0 |  | 优先级评分（0-1） |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `user_id` | `text` | YES |  | FK → users.id | 所属用户ID |
| `metadata` | `jsonb` | YES |  |  | 扩展元数据，JSON |
| `tags` | `ARRAY` | YES |  |  | 标签列表，数组 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |
| `user_memory_id` | `user_memories` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `user_memories_preferences_conclusion_directives_vector_index` | `CREATE INDEX user_memories_preferences_conclusion_directives_vector_index ON public.user_memories_preferences USING hnsw (conclusion_directives_vector vector_cosine_ops)` |
