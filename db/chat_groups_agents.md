# chat_groups_agents

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `chat_group_id` | `text` | NO |  | PK, FK → chat_groups.id | 关联的聊天组ID |
| `agent_id` | `text` | NO |  | PK, FK → agents.id | 参与该组的Agent ID |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `enabled` | `boolean` | YES | true |  | 该Agent在组内是否激活 |
| `order` | `integer` | YES | 0 |  | Agent在组内的排列/发言顺序 |
| `role` | `text` | YES | 'participant'::text |  | Agent在组内的角色，如 `moderator`/`participant` |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `agent_id` | `agents` | `id` |
| `chat_group_id` | `chat_groups` | `id` |
| `user_id` | `users` | `id` |
