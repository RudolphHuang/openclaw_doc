# user_memories_experiences

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `character varying(255)` | NO |  | PK | 经历记忆ID |
| `user_memory_id` | `character varying(255)` | YES |  | FK → user_memories.id | 关联的主记忆ID |
| `type` | `character varying(255)` | YES |  |  | 经历类型 |
| `situation` | `text` | YES |  |  | 经历发生的情境描述 |
| `situation_vector` | `USER-DEFINED` | YES |  |  | 情境的1024维向量（HNSW索引） |
| `reasoning` | `text` | YES |  |  | 推理分析过程 |
| `possible_outcome` | `text` | YES |  |  | 可能的结果预测 |
| `action` | `text` | YES |  |  | 采取的行动描述 |
| `action_vector` | `USER-DEFINED` | YES |  |  | 行动的1024维向量（HNSW索引） |
| `key_learning` | `text` | YES |  |  | 关键学习/收获 |
| `key_learning_vector` | `USER-DEFINED` | YES |  |  | 关键学习的1024维向量（HNSW索引） |
| `metadata` | `jsonb` | YES |  |  | 扩展元数据，JSON |
| `score_confidence` | `real` | YES | 0 |  | 置信度评分（0-1） |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `user_id` | `text` | YES |  | FK → users.id | 所属用户ID |
| `tags` | `ARRAY` | YES |  |  | 标签列表，数组 |

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
