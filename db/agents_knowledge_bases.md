# agents_knowledge_bases

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `agent_id` | `text` | NO |  | PK, FK → agents.id | 关联的Agent ID |
| `knowledge_base_id` | `text` | NO |  | PK, FK → knowledge_bases.id | 关联的知识库ID |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `enabled` | `boolean` | YES | true |  | 该知识库在此Agent中是否启用 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `agent_id` | `agents` | `id` |
| `knowledge_base_id` | `knowledge_bases` | `id` |
| `user_id` | `users` | `id` |
