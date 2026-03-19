# session_groups

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK |  |
| `name` | `text` | NO |  |  |  |
| `sort` | `integer` | YES |  |  |  |
| `user_id` | `text` | NO |  | FK → users.id |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `client_id` | `text` | YES |  |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `session_groups_client_id_user_id_unique` | `CREATE UNIQUE INDEX session_groups_client_id_user_id_unique ON public.session_groups USING btree (client_id, user_id)` |
