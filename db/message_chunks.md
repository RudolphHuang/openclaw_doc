# message_chunks

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `message_id` | `text` | NO |  | PK, FK → messages.id |  |
| `chunk_id` | `uuid` | NO |  | PK, FK → chunks.id |  |
| `user_id` | `text` | NO |  | FK → users.id |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `chunk_id` | `chunks` | `id` |
| `message_id` | `messages` | `id` |
| `user_id` | `users` | `id` |
