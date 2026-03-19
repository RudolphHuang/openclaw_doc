# user_memories_contexts

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `character varying(255)` | NO |  | PK | 上下文记忆ID |
| `user_memory_ids` | `jsonb` | YES |  |  | 关联的记忆ID列表，JSON |
| `associated_objects` | `jsonb` | YES |  |  | 关联的对象（物品、地点等），JSON |
| `associated_subjects` | `jsonb` | YES |  |  | 关联的主体（人物等），JSON |
| `title` | `text` | YES |  |  | 上下文标题 |
| `title_vector` | `USER-DEFINED` | YES |  |  | 标题的1024维向量（HNSW索引） |
| `description` | `text` | YES |  |  | 上下文描述 |
| `description_vector` | `USER-DEFINED` | YES |  |  | 描述的1024维向量（HNSW索引） |
| `type` | `character varying(255)` | YES |  |  | 上下文类型 |
| `current_status` | `text` | YES |  |  | 当前状态描述 |
| `score_impact` | `numeric` | YES | 0 |  | 影响力评分（0-1） |
| `score_urgency` | `numeric` | YES | 0 |  | 紧迫度评分（0-1） |
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

## 索引

| 索引名 | 定义 |
|--------|------|
| `user_memories_contexts_description_vector_index` | `CREATE INDEX user_memories_contexts_description_vector_index ON public.user_memories_contexts USING hnsw (description_vector vector_cosine_ops)` |
| `user_memories_contexts_title_vector_index` | `CREATE INDEX user_memories_contexts_title_vector_index ON public.user_memories_contexts USING hnsw (title_vector vector_cosine_ops)` |
| `user_memories_contexts_type_index` | `CREATE INDEX user_memories_contexts_type_index ON public.user_memories_contexts USING btree (type)` |
