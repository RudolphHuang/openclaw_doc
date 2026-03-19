# oidc_grants

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `character varying(255)` | NO |  | PK | OIDC授权记录的唯一标识 |
| `data` | `jsonb` | NO |  |  | oidc-provider序列化的完整数据，JSON |
| `expires_at` | `timestamp with time zone` | NO |  |  | 过期时间 |
| `consumed_at` | `timestamp with time zone` | YES |  |  | 消费/使用时间（一次性令牌） |
| `user_id` | `text` | NO |  | FK → users.id | 关联的用户ID |
| `client_id` | `character varying(255)` | NO |  |  | 关联的OIDC客户端ID |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |
