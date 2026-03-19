# nextauth_sessions

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `expires` | `timestamp without time zone` | NO |  |  | 会话过期时间 |
| `sessionToken` | `text` | NO |  | PK | 会话令牌（主键，存储在Cookie中） |
| `userId` | `text` | NO |  | FK → users.id | 关联的用户ID |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `userId` | `users` | `id` |
