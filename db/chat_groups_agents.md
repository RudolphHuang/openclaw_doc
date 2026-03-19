# chat_groups_agents

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `chat_group_id` | `text` | NO |  | PK, FK → chat_groups.id |  |
| `agent_id` | `text` | NO |  | PK, FK → agents.id |  |
| `user_id` | `text` | NO |  | FK → users.id |  |
| `enabled` | `boolean` | YES | true |  |  |
| `order` | `integer` | YES | 0 |  |  |
| `role` | `text` | YES | 'participant'::text |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `agent_id` | `agents` | `id` |
| `chat_group_id` | `chat_groups` | `id` |
| `user_id` | `users` | `id` |
