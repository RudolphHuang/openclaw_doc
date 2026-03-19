# message_groups

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `character varying(255)` | NO |  | PK | 消息组ID（多模型并行回复组） |
| `topic_id` | `text` | YES |  | FK → topics.id | 所属话题ID |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `parent_group_id` | `character varying(255)` | YES |  | FK → message_groups.id | 父消息组ID（支持嵌套） |
| `parent_message_id` | `text` | YES |  | FK → messages.id | 触发该组的用户消息ID |
| `title` | `character varying(255)` | YES |  |  | 消息组标题 |
| `description` | `text` | YES |  |  | 消息组描述 |
| `client_id` | `character varying(255)` | YES |  |  | 客户端本地ID |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |

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
