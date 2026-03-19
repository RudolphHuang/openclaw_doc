# oidc_consents

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `user_id` | `text` | NO |  | PK, FK → users.id |  |
| `client_id` | `character varying(255)` | NO |  | PK, FK → oidc_clients.id |  |
| `scopes` | `ARRAY` | NO |  |  |  |
| `expires_at` | `timestamp with time zone` | YES |  |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `client_id` | `oidc_clients` | `id` |
| `user_id` | `users` | `id` |
