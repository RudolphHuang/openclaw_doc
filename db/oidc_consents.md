# oidc_consents

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `user_id` | `text` | NO |  | PK, FK → users.id | 用户ID |
| `client_id` | `character varying(255)` | NO |  | PK, FK → oidc_clients.id | 关联的OIDC客户端ID |
| `scopes` | `ARRAY` | NO |  |  | 用户已同意授权的权限范围，数组 |
| `expires_at` | `timestamp with time zone` | YES |  |  | 同意记录过期时间 |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `client_id` | `oidc_clients` | `id` |
| `user_id` | `users` | `id` |
