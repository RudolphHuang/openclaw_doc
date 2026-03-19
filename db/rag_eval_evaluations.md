# rag_eval_evaluations

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `integer` | NO |  | PK |  |
| `name` | `text` | NO |  |  |  |
| `description` | `text` | YES |  |  |  |
| `eval_records_url` | `text` | YES |  |  |  |
| `status` | `text` | YES |  |  |  |
| `error` | `jsonb` | YES |  |  |  |
| `dataset_id` | `integer` | NO |  | FK → rag_eval_datasets.id |  |
| `knowledge_base_id` | `text` | YES |  | FK → knowledge_bases.id |  |
| `language_model` | `text` | YES |  |  |  |
| `embedding_model` | `text` | YES |  |  |  |
| `user_id` | `text` | YES |  | FK → users.id |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `dataset_id` | `rag_eval_datasets` | `id` |
| `knowledge_base_id` | `knowledge_bases` | `id` |
| `user_id` | `users` | `id` |
