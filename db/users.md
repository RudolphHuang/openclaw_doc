# users

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK |  |
| `username` | `text` | YES |  | UQ |  |
| `email` | `text` | YES |  |  |  |
| `avatar` | `text` | YES |  |  |  |
| `phone` | `text` | YES |  |  |  |
| `first_name` | `text` | YES |  |  |  |
| `last_name` | `text` | YES |  |  |  |
| `is_onboarded` | `boolean` | YES | false |  |  |
| `clerk_created_at` | `timestamp with time zone` | YES |  |  |  |
| `preference` | `jsonb` | YES |  |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `full_name` | `text` | YES |  |  |  |
| `email_verified_at` | `timestamp with time zone` | YES |  |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `utm_source` | `character varying(255)` | YES |  |  |  |
| `utm_medium` | `character varying(255)` | YES |  |  |  |
| `utm_campaign` | `character varying(255)` | YES |  |  |  |

## 索引

| 索引名 | 定义 |
|--------|------|
| `users_username_unique` | `CREATE UNIQUE INDEX users_username_unique ON public.users USING btree (username)` |
