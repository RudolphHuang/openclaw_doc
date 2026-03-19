# nextauth_accounts

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `access_token` | `text` | YES |  |  |  |
| `expires_at` | `integer` | YES |  |  |  |
| `id_token` | `text` | YES |  |  |  |
| `provider` | `text` | NO |  | PK |  |
| `providerAccountId` | `text` | NO |  | PK |  |
| `refresh_token` | `text` | YES |  |  |  |
| `scope` | `text` | YES |  |  |  |
| `session_state` | `text` | YES |  |  |  |
| `token_type` | `text` | YES |  |  |  |
| `type` | `text` | NO |  |  |  |
| `userId` | `text` | NO |  | FK → users.id |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `userId` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `idx_nextauth_accounts_provider_account_id` | `CREATE INDEX idx_nextauth_accounts_provider_account_id ON public.nextauth_accounts USING btree ("providerAccountId")` |
| `idx_nextauth_accounts_user_id` | `CREATE INDEX idx_nextauth_accounts_user_id ON public.nextauth_accounts USING btree ("userId")` |
