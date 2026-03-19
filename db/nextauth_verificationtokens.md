# nextauth_verificationtokens

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `expires` | `timestamp without time zone` | NO |  |  | 验证令牌过期时间 |
| `identifier` | `text` | NO |  | PK | 验证标识符（通常为邮箱地址） |
| `token` | `text` | NO |  | PK | 验证令牌值（一次性使用） |
