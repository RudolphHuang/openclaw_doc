# message_groups

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `character varying(255)` | NO |  | PK |  |
| `topic_id` | `text` | YES |  | FK → topics.id |  |
| `user_id` | `text` | NO |  | FK → users.id |  |
| `parent_group_id` | `character varying(255)` | YES |  | FK → message_groups.id |  |
| `parent_message_id` | `text` | YES |  | FK → messages.id |  |
| `title` | `character varying(255)` | YES |  |  |  |
| `description` | `text` | YES |  |  |  |
| `client_id` | `character varying(255)` | YES |  |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `parent_group_id` | `message_groups` | `id` |
| `parent_message_id` | `messages` | `id` |
| `topic_id` | `topics` | `id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `message_groups_client_id_user_id_unique` | `CREATE UNIQUE INDEX message_groups_client_id_user_id_unique ON public.message_groups USING btree (client_id, user_id)` |
