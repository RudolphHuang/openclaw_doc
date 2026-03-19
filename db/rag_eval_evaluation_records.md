# rag_eval_evaluation_records

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `integer` | NO |  | PK |  |
| `question` | `text` | NO |  |  |  |
| `answer` | `text` | YES |  |  |  |
| `context` | `ARRAY` | YES |  |  |  |
| `ideal` | `text` | YES |  |  |  |
| `status` | `text` | YES |  |  |  |
| `error` | `jsonb` | YES |  |  |  |
| `language_model` | `text` | YES |  |  |  |
| `embedding_model` | `text` | YES |  |  |  |
| `question_embedding_id` | `uuid` | YES |  | FK → embeddings.id |  |
| `duration` | `integer` | YES |  |  |  |
| `dataset_record_id` | `integer` | NO |  | FK → rag_eval_dataset_records.id |  |
| `evaluation_id` | `integer` | NO |  | FK → rag_eval_evaluations.id |  |
| `user_id` | `text` | YES |  | FK → users.id |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `dataset_record_id` | `rag_eval_dataset_records` | `id` |
| `evaluation_id` | `rag_eval_evaluations` | `id` |
| `question_embedding_id` | `embeddings` | `id` |
| `user_id` | `users` | `id` |
