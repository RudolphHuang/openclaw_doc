# async_tasks

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `uuid` | NO | gen_random_uuid() | PK |  |
| `type` | `text` | YES |  |  |  |
| `status` | `text` | YES |  |  |  |
| `error` | `jsonb` | YES |  |  |  |
| `user_id` | `text` | NO |  | FK → users.id |  |
| `duration` | `integer` | YES |  |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |
