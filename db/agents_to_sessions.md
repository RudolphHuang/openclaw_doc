# agents_to_sessions

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `agent_id` | `text` | NO |  | PK, FK → agents.id | 关联的Agent ID |
| `session_id` | `text` | NO |  | PK, FK → sessions.id | 关联的会话ID |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `agent_id` | `agents` | `id` |
| `session_id` | `sessions` | `id` |
| `user_id` | `users` | `id` |
