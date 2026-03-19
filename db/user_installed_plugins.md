# user_installed_plugins

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `user_id` | `text` | NO |  | PK, FK → users.id |  |
| `identifier` | `text` | NO |  | PK |  |
| `type` | `text` | NO |  |  |  |
| `manifest` | `jsonb` | YES |  |  |  |
| `settings` | `jsonb` | YES |  |  |  |
| `custom_params` | `jsonb` | YES |  |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |
