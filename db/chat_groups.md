# chat_groups

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK |  |
| `title` | `text` | YES |  |  |  |
| `description` | `text` | YES |  |  |  |
| `config` | `jsonb` | YES |  |  |  |
| `client_id` | `text` | YES |  |  |  |
| `user_id` | `text` | NO |  | FK → users.id |  |
| `pinned` | `boolean` | YES | false |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `group_id` | `text` | YES |  | FK → session_groups.id |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `group_id` | `session_groups` | `id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `chat_groups_client_id_user_id_unique` | `CREATE UNIQUE INDEX chat_groups_client_id_user_id_unique ON public.chat_groups USING btree (client_id, user_id)` |
