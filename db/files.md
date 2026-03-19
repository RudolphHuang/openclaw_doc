# files

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK | 文件ID，格式 `file_xxx` |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `file_type` | `character varying(255)` | NO |  |  | 文件MIME类型 |
| `name` | `text` | NO |  |  | 文件名 |
| `size` | `integer` | NO |  |  | 文件大小（字节） |
| `url` | `text` | NO |  |  | 文件访问URL（S3/OSS等） |
| `metadata` | `jsonb` | YES |  |  | 文件元数据，JSON |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `file_hash` | `character varying(64)` | YES |  | FK → global_files.hash_id | 文件SHA-256哈希，关联全局文件表做去重 |
| `chunk_task_id` | `uuid` | YES |  | FK → async_tasks.id | 关联的文件分块异步任务ID |
| `embedding_task_id` | `uuid` | YES |  | FK → async_tasks.id | 关联的向量化异步任务ID |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `client_id` | `text` | YES |  |  | 客户端本地ID |
| `source` | `text` | YES |  |  | 文件来源类型（FileSource枚举） |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `chunk_task_id` | `async_tasks` | `id` |
| `embedding_task_id` | `async_tasks` | `id` |
| `file_hash` | `global_files` | `hash_id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `file_hash_idx` | `CREATE INDEX file_hash_idx ON public.files USING btree (file_hash)` |
| `files_client_id_user_id_unique` | `CREATE UNIQUE INDEX files_client_id_user_id_unique ON public.files USING btree (client_id, user_id)` |
