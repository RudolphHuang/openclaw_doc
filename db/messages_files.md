# messages_files

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `file_id` | `text` | NO |  | PK, FK → files.id | 关联的文件ID |
| `message_id` | `text` | NO |  | PK, FK → messages.id | 关联的消息ID |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `file_id` | `files` | `id` |
| `message_id` | `messages` | `id` |
| `user_id` | `users` | `id` |
