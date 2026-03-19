# rag_eval_datasets

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `integer` | NO |  | PK |  |
| `description` | `text` | YES |  |  |  |
| `name` | `text` | NO |  |  |  |
| `knowledge_base_id` | `text` | YES |  | FK → knowledge_bases.id |  |
| `user_id` | `text` | YES |  | FK → users.id |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `knowledge_base_id` | `knowledge_bases` | `id` |
| `user_id` | `users` | `id` |
