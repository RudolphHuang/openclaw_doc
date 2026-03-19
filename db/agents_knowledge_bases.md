# agents_knowledge_bases

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `agent_id` | `text` | NO |  | PK, FK → agents.id |  |
| `knowledge_base_id` | `text` | NO |  | PK, FK → knowledge_bases.id |  |
| `user_id` | `text` | NO |  | FK → users.id |  |
| `enabled` | `boolean` | YES | true |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `agent_id` | `agents` | `id` |
| `knowledge_base_id` | `knowledge_bases` | `id` |
| `user_id` | `users` | `id` |
