# oidc_access_tokens

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `character varying(255)` | NO |  | PK |  |
| `data` | `jsonb` | NO |  |  |  |
| `expires_at` | `timestamp with time zone` | NO |  |  |  |
| `consumed_at` | `timestamp with time zone` | YES |  |  |  |
| `user_id` | `text` | NO |  | FK → users.id |  |
| `client_id` | `character varying(255)` | NO |  |  |  |
| `grant_id` | `character varying(255)` | YES |  |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |
