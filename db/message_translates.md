# message_translates

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK, FK → messages.id | 与 messages.id 相同（1:1关系扩展表） |
| `content` | `text` | YES |  |  | 翻译后的消息内容 |
| `from` | `text` | YES |  |  | 源语言代码，如 `zh` |
| `to` | `text` | YES |  |  | 目标语言代码，如 `en` |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `client_id` | `text` | YES |  |  | 客户端本地ID |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `id` | `messages` | `id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `message_translates_client_id_user_id_unique` | `CREATE UNIQUE INDEX message_translates_client_id_user_id_unique ON public.message_translates USING btree (client_id, user_id)` |
