# async_tasks

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `uuid` | NO | gen_random_uuid() | PK | UUID主键 |
| `type` | `text` | YES |  |  | 任务类型，如文件分块/向量化 |
| `status` | `text` | YES |  |  | 任务状态：pending/processing/success/error |
| `error` | `jsonb` | YES |  |  | 错误信息，JSON |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `duration` | `integer` | YES |  |  | 任务执行耗时（毫秒） |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |
