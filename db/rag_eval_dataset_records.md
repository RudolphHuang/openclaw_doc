# rag_eval_dataset_records

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `integer` | NO |  | PK | 记录ID（自增） |
| `dataset_id` | `integer` | NO |  | FK → rag_eval_datasets.id | 所属评估数据集ID |
| `ideal` | `text` | YES |  |  | 标准答案/期望回答 |
| `question` | `text` | YES |  |  | 测试问题 |
| `reference_files` | `ARRAY` | YES |  |  | 参考文件列表，数组 |
| `metadata` | `jsonb` | YES |  |  | 额外元数据，JSON |
| `user_id` | `text` | YES |  | FK → users.id | 所属用户ID |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `dataset_id` | `rag_eval_datasets` | `id` |
| `user_id` | `users` | `id` |
