# nextauth_accounts

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `access_token` | `text` | YES |  |  | OAuth访问令牌 |
| `expires_at` | `integer` | YES |  |  | access_token过期时间（Unix时间戳） |
| `id_token` | `text` | YES |  |  | OpenID Connect ID令牌 |
| `provider` | `text` | NO |  | PK | OAuth提供商名称，如 `github`/`google` |
| `providerAccountId` | `text` | NO |  | PK | 用户在该OAuth提供商的账号ID |
| `refresh_token` | `text` | YES |  |  | OAuth刷新令牌 |
| `scope` | `text` | YES |  |  | 授权的权限范围 |
| `session_state` | `text` | YES |  |  | OAuth会话状态 |
| `token_type` | `text` | YES |  |  | 令牌类型，通常为 `bearer` |
| `type` | `text` | NO |  |  | 账号类型（AdapterAccount类型） |
| `userId` | `text` | NO |  | FK → users.id | 关联的本地用户ID |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `userId` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `idx_nextauth_accounts_provider_account_id` | `CREATE INDEX idx_nextauth_accounts_provider_account_id ON public.nextauth_accounts USING btree ("providerAccountId")` |
| `idx_nextauth_accounts_user_id` | `CREATE INDEX idx_nextauth_accounts_user_id ON public.nextauth_accounts USING btree ("userId")` |
