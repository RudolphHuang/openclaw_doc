# user_memories

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `character varying(255)` | NO |  | PK | 记忆ID，格式 `memory_xxx` |
| `user_id` | `text` | YES |  | FK → users.id | 所属用户ID |
| `memory_category` | `character varying(255)` | YES |  |  | 记忆分类 |
| `memory_layer` | `character varying(255)` | YES |  |  | 记忆层级（短期/长期等） |
| `memory_type` | `character varying(255)` | YES |  |  | 记忆类型 |
| `title` | `character varying(255)` | YES |  |  | 记忆标题 |
| `summary` | `text` | YES |  |  | 记忆摘要文本 |
| `summary_vector_1024` | `USER-DEFINED` | YES |  |  | 摘要的1024维向量（HNSW索引，余弦相似度） |
| `details` | `text` | YES |  |  | 记忆详细内容 |
| `details_vector_1024` | `USER-DEFINED` | YES |  |  | 详细内容的1024维向量（HNSW索引） |
| `status` | `character varying(255)` | YES |  |  | 记忆状态 |
| `accessed_count` | `bigint` | YES | 0 |  | 被访问次数（用于记忆重要性评估） |
| `last_accessed_at` | `timestamp with time zone` | NO |  |  | 最近访问时间 |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `metadata` | `jsonb` | YES |  |  | 扩展元数据，JSON |
| `tags` | `ARRAY` | YES |  |  | 标签列表，数组 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `user_memories_details_vector_1024_index` | `CREATE INDEX user_memories_details_vector_1024_index ON public.user_memories USING hnsw (details_vector_1024 vector_cosine_ops)` |
| `user_memories_summary_vector_1024_index` | `CREATE INDEX user_memories_summary_vector_1024_index ON public.user_memories USING hnsw (summary_vector_1024 vector_cosine_ops)` |
