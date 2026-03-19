# rag_eval_evaluation_records

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `integer` | NO |  | PK | 评估记录ID（自增） |
| `question` | `text` | NO |  |  | 测试问题 |
| `answer` | `text` | YES |  |  | 模型实际回答 |
| `context` | `ARRAY` | YES |  |  | RAG检索到的上下文列表，数组 |
| `ideal` | `text` | YES |  |  | 标准答案 |
| `status` | `text` | YES |  |  | 单条评估状态 |
| `error` | `jsonb` | YES |  |  | 错误信息，JSON |
| `language_model` | `text` | YES |  |  | 使用的语言模型 |
| `embedding_model` | `text` | YES |  |  | 使用的向量模型 |
| `question_embedding_id` | `uuid` | YES |  | FK → embeddings.id | 问题向量化后的embedding ID |
| `duration` | `integer` | YES |  |  | 该条评估耗时（毫秒） |
| `dataset_record_id` | `integer` | NO |  | FK → rag_eval_dataset_records.id | 关联的数据集记录ID |
| `evaluation_id` | `integer` | NO |  | FK → rag_eval_evaluations.id | 所属评估任务ID |
| `user_id` | `text` | YES |  | FK → users.id | 所属用户ID |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `dataset_record_id` | `rag_eval_dataset_records` | `id` |
| `evaluation_id` | `rag_eval_evaluations` | `id` |
| `question_embedding_id` | `embeddings` | `id` |
| `user_id` | `users` | `id` |
