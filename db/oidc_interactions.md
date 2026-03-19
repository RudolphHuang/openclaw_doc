# oidc_interactions

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `character varying(255)` | NO |  | PK | OIDC交互会话的唯一标识 |
| `data` | `jsonb` | NO |  |  | oidc-provider序列化的完整数据，JSON |
| `expires_at` | `timestamp with time zone` | NO |  |  | 过期时间 |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
