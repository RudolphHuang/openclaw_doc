# rag_eval_datasets

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `integer` | NO |  | PK | 数据集ID（自增，从30000开始） |
| `description` | `text` | YES |  |  | 数据集描述 |
| `name` | `text` | NO |  |  | 数据集名称 |
| `knowledge_base_id` | `text` | YES |  | FK → knowledge_bases.id | 关联的知识库ID |
| `user_id` | `text` | YES |  | FK → users.id | 所属用户ID |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `knowledge_base_id` | `knowledge_bases` | `id` |
| `user_id` | `users` | `id` |
