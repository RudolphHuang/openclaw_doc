# generations

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK |  |
| `user_id` | `text` | NO |  | FK → users.id |  |
| `generation_batch_id` | `character varying(64)` | NO |  | FK → generation_batches.id |  |
| `async_task_id` | `uuid` | YES |  | FK → async_tasks.id |  |
| `file_id` | `text` | YES |  | FK → files.id |  |
| `seed` | `integer` | YES |  |  |  |
| `asset` | `jsonb` | YES |  |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `async_task_id` | `async_tasks` | `id` |
| `file_id` | `files` | `id` |
| `generation_batch_id` | `generation_batches` | `id` |
| `user_id` | `users` | `id` |
