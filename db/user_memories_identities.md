# user_memories_identities

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `description` | `text` | YES |  |  | 身份描述文本 |
| `description_vector` | `USER-DEFINED` | YES |  |  | 描述的1024维向量（HNSW索引） |
| `id` | `character varying(255)` | NO |  | PK | 身份记忆ID |
| `relationship` | `character varying(255)` | YES |  |  | 与用户的关系描述 |
| `role` | `text` | YES |  |  | 身份角色描述 |
| `type` | `character varying(255)` | YES |  |  | 身份类型（人物、组织等） |
| `user_memory_id` | `character varying(255)` | YES |  | FK → user_memories.id | 关联的主记忆ID |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `user_id` | `text` | YES |  | FK → users.id | 所属用户ID |
| `metadata` | `jsonb` | YES |  |  | 扩展元数据，JSON |
| `tags` | `ARRAY` | YES |  |  | 标签列表，数组 |
| `episodic_date` | `timestamp with time zone` | YES |  |  | 该身份记忆对应的时间点 |

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
