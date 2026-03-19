# nextauth_sessions

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `expires` | `timestamp without time zone` | NO |  |  |  |
| `sessionToken` | `text` | NO |  | PK |  |
| `userId` | `text` | NO |  | FK → users.id |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `userId` | `users` | `id` |
