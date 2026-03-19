# topic_documents

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `document_id` | `text` | NO |  | PK, FK → documents.id | 关联的文档ID |
| `topic_id` | `text` | NO |  | PK, FK → topics.id | 关联的话题ID |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `document_id` | `documents` | `id` |
| `topic_id` | `topics` | `id` |
| `user_id` | `users` | `id` |
