# files_to_sessions

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `file_id` | `text` | NO |  | PK, FK → files.id |  |
| `session_id` | `text` | NO |  | PK, FK → sessions.id |  |
| `user_id` | `text` | NO |  | FK → users.id |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `file_id` | `files` | `id` |
| `session_id` | `sessions` | `id` |
| `user_id` | `users` | `id` |
