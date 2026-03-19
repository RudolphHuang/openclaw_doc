# message_queries

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `uuid` | NO | gen_random_uuid() | PK | UUID主键 |
| `message_id` | `text` | NO |  | FK → messages.id | 关联的消息ID（该消息触发了RAG查询） |
| `rewrite_query` | `text` | YES |  |  | RAG查询改写后的查询文本 |
| `user_query` | `text` | YES |  |  | 用户原始查询文本 |
| `embeddings_id` | `uuid` | YES |  | FK → embeddings.id | 查询向量的embedding ID |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `client_id` | `text` | YES |  |  | 客户端本地ID |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `embeddings_id` | `embeddings` | `id` |
| `message_id` | `messages` | `id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `message_queries_client_id_user_id_unique` | `CREATE UNIQUE INDEX message_queries_client_id_user_id_unique ON public.message_queries USING btree (client_id, user_id)` |
