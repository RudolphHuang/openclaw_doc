# message_plugins

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK, FK → messages.id |  |
| `tool_call_id` | `text` | YES |  |  |  |
| `type` | `text` | YES | 'default'::text |  |  |
| `api_name` | `text` | YES |  |  |  |
| `arguments` | `text` | YES |  |  |  |
| `identifier` | `text` | YES |  |  |  |
| `state` | `jsonb` | YES |  |  |  |
| `error` | `jsonb` | YES |  |  |  |
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
| `message_plugins_client_id_user_id_unique` | `CREATE UNIQUE INDEX message_plugins_client_id_user_id_unique ON public.message_plugins USING btree (client_id, user_id)` |
