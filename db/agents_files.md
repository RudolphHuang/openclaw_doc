# agents_files

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `file_id` | `text` | NO |  | PK, FK → files.id |  |
| `agent_id` | `text` | NO |  | PK, FK → agents.id |  |
| `enabled` | `boolean` | YES | true |  |  |
| `user_id` | `text` | NO |  | PK, FK → users.id |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `agent_id` | `agents` | `id` |
| `file_id` | `files` | `id` |
| `user_id` | `users` | `id` |
