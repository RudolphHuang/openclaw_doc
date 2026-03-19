# sessions

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK |  |
| `slug` | `character varying(100)` | NO |  |  |  |
| `title` | `text` | YES |  |  |  |
| `description` | `text` | YES |  |  |  |
| `avatar` | `text` | YES |  |  |  |
| `background_color` | `text` | YES |  |  |  |
| `type` | `text` | YES | 'agent'::text |  |  |
| `user_id` | `text` | NO |  | FK → users.id |  |
| `group_id` | `text` | YES |  | FK → session_groups.id |  |
| `pinned` | `boolean` | YES | false |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `client_id` | `text` | YES |  |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `group_id` | `session_groups` | `id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `sessions_client_id_user_id_unique` | `CREATE UNIQUE INDEX sessions_client_id_user_id_unique ON public.sessions USING btree (client_id, user_id)` |
| `sessions_id_user_id_idx` | `CREATE INDEX sessions_id_user_id_idx ON public.sessions USING btree (id, user_id)` |
| `sessions_user_id_idx` | `CREATE INDEX sessions_user_id_idx ON public.sessions USING btree (user_id)` |
| `slug_user_id_unique` | `CREATE UNIQUE INDEX slug_user_id_unique ON public.sessions USING btree (slug, user_id)` |
