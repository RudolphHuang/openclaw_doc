# generations

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK | 单张图片生成记录ID |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `generation_batch_id` | `character varying(64)` | NO |  | FK → generation_batches.id | 所属批次ID |
| `async_task_id` | `uuid` | YES |  | FK → async_tasks.id | 关联的异步任务ID（生成进行中） |
| `file_id` | `text` | YES |  | FK → files.id | 生成完成后关联的文件ID |
| `seed` | `integer` | YES |  |  | 生成随机种子（用于复现） |
| `asset` | `jsonb` | YES |  |  | 生成资源信息（S3 key、实际宽高、缩略图等），JSON |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `async_task_id` | `async_tasks` | `id` |
| `file_id` | `files` | `id` |
| `generation_batch_id` | `generation_batches` | `id` |
| `user_id` | `users` | `id` |
