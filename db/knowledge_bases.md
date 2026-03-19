# knowledge_bases

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK |  |
| `name` | `text` | NO |  |  |  |
| `description` | `text` | YES |  |  |  |
| `avatar` | `text` | YES |  |  |  |
| `type` | `text` | YES |  |  |  |
| `user_id` | `text` | NO |  | FK → users.id |  |
| `is_public` | `boolean` | YES | false |  |  |
| `settings` | `jsonb` | YES |  |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `client_id` | `text` | YES |  |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `knowledge_bases_client_id_user_id_unique` | `CREATE UNIQUE INDEX knowledge_bases_client_id_user_id_unique ON public.knowledge_bases USING btree (client_id, user_id)` |
