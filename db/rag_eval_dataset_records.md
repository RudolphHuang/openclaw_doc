# rag_eval_dataset_records

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `integer` | NO |  | PK |  |
| `dataset_id` | `integer` | NO |  | FK → rag_eval_datasets.id |  |
| `ideal` | `text` | YES |  |  |  |
| `question` | `text` | YES |  |  |  |
| `reference_files` | `ARRAY` | YES |  |  |  |
| `metadata` | `jsonb` | YES |  |  |  |
| `user_id` | `text` | YES |  | FK → users.id |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `dataset_id` | `rag_eval_datasets` | `id` |
| `user_id` | `users` | `id` |
