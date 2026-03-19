# message_query_chunks

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK, FK → messages.id |  |
| `query_id` | `uuid` | NO |  | PK, FK → message_queries.id |  |
| `chunk_id` | `uuid` | NO |  | PK, FK → chunks.id |  |
| `similarity` | `numeric` | YES |  |  |  |
| `user_id` | `text` | NO |  | FK → users.id |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `chunk_id` | `chunks` | `id` |
| `id` | `messages` | `id` |
| `query_id` | `message_queries` | `id` |
| `user_id` | `users` | `id` |
