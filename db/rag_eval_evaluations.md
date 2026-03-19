# rag_eval_evaluations

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `integer` | NO |  | PK | 评估任务ID（自增） |
| `name` | `text` | NO |  |  | 评估任务名称 |
| `description` | `text` | YES |  |  | 评估任务描述 |
| `eval_records_url` | `text` | YES |  |  | 评估结果导出URL |
| `status` | `text` | YES |  |  | 评估状态（pending/processing/done/error等） |
| `error` | `jsonb` | YES |  |  | 错误信息，JSON |
| `dataset_id` | `integer` | NO |  | FK → rag_eval_datasets.id | 使用的数据集ID |
| `knowledge_base_id` | `text` | YES |  | FK → knowledge_bases.id | 被评估的知识库ID |
| `language_model` | `text` | YES |  |  | 评估使用的语言模型 |
| `embedding_model` | `text` | YES |  |  | 评估使用的向量模型 |
| `user_id` | `text` | YES |  | FK → users.id | 所属用户ID |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `dataset_id` | `rag_eval_datasets` | `id` |
| `knowledge_base_id` | `knowledge_bases` | `id` |
| `user_id` | `users` | `id` |
