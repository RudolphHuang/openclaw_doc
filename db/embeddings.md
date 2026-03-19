# embeddings

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `uuid` | NO | gen_random_uuid() | PK | UUID主键 |
| `chunk_id` | `uuid` | YES |  | UQ, FK → chunks.id | 关联的文本块ID（唯一，一块一向量） |
| `embeddings` | `USER-DEFINED` | YES |  |  | 1024维向量（pgvector类型） |
| `model` | `text` | YES |  |  | 生成该向量使用的嵌入模型名称 |
| `user_id` | `text` | YES |  | FK → users.id | 所属用户ID |
| `client_id` | `text` | YES |  |  | 客户端本地ID |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `chunk_id` | `chunks` | `id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `embeddings_chunk_id_idx` | `CREATE INDEX embeddings_chunk_id_idx ON public.embeddings USING btree (chunk_id)` |
| `embeddings_chunk_id_unique` | `CREATE UNIQUE INDEX embeddings_chunk_id_unique ON public.embeddings USING btree (chunk_id)` |
| `embeddings_client_id_user_id_unique` | `CREATE UNIQUE INDEX embeddings_client_id_user_id_unique ON public.embeddings USING btree (client_id, user_id)` |
