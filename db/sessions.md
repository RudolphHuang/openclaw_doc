# sessions

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK | 会话ID，格式 `sess_xxx` |
| `slug` | `character varying(100)` | NO |  |  | URL友好标识，随机生成，用户+slug唯一 |
| `title` | `text` | YES |  |  | 会话标题 |
| `description` | `text` | YES |  |  | 会话描述 |
| `avatar` | `text` | YES |  |  | 会话头像 |
| `background_color` | `text` | YES |  |  | 会话背景颜色 |
| `type` | `text` | YES | 'agent'::text |  | 会话类型：`agent`（单Agent）/`group`（多Agent群聊） |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `group_id` | `text` | YES |  | FK → session_groups.id | 所属分组ID（session_groups） |
| `pinned` | `boolean` | YES | false |  | 是否置顶 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `client_id` | `text` | YES |  |  | 客户端本地ID |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |

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
