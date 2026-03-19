# message_translates

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK, FK → messages.id |  |
| `content` | `text` | YES |  |  |  |
| `from` | `text` | YES |  |  |  |
| `to` | `text` | YES |  |  |  |
| `user_id` | `text` | NO |  | FK → users.id |  |
| `client_id` | `text` | YES |  |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `id` | `messages` | `id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `message_translates_client_id_user_id_unique` | `CREATE UNIQUE INDEX message_translates_client_id_user_id_unique ON public.message_translates USING btree (client_id, user_id)` |
