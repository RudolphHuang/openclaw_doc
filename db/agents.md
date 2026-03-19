# agents

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK |  |
| `slug` | `character varying(100)` | YES |  | UQ |  |
| `title` | `character varying(255)` | YES |  |  |  |
| `description` | `character varying(1000)` | YES |  |  |  |
| `tags` | `jsonb` | YES | '[]'::jsonb |  |  |
| `avatar` | `text` | YES |  |  |  |
| `background_color` | `text` | YES |  |  |  |
| `plugins` | `jsonb` | YES | '[]'::jsonb |  |  |
| `user_id` | `text` | NO |  | FK → users.id |  |
| `chat_config` | `jsonb` | YES |  |  |  |
| `few_shots` | `jsonb` | YES |  |  |  |
| `model` | `text` | YES |  |  |  |
| `params` | `jsonb` | YES | '{}'::jsonb |  |  |
| `provider` | `text` | YES |  |  |  |
| `system_role` | `text` | YES |  |  |  |
| `tts` | `jsonb` | YES |  |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `client_id` | `text` | YES |  |  |  |
| `opening_message` | `text` | YES |  |  |  |
| `opening_questions` | `ARRAY` | YES | '{}'::text[] |  |  |
| `virtual` | `boolean` | YES | false |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `agents_description_idx` | `CREATE INDEX agents_description_idx ON public.agents USING btree (description)` |
| `agents_slug_unique` | `CREATE UNIQUE INDEX agents_slug_unique ON public.agents USING btree (slug)` |
| `agents_title_idx` | `CREATE INDEX agents_title_idx ON public.agents USING btree (title)` |
| `client_id_user_id_unique` | `CREATE UNIQUE INDEX client_id_user_id_unique ON public.agents USING btree (client_id, user_id)` |
