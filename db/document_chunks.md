# document_chunks

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `document_id` | `character varying(30)` | NO |  | PK, FK → documents.id | 关联的文档ID |
| `chunk_id` | `uuid` | NO |  | PK, FK → chunks.id | 关联的分块ID |
| `page_index` | `integer` | YES |  |  | 该块所在文档页码 |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `chunk_id` | `chunks` | `id` |
| `document_id` | `documents` | `id` |
| `user_id` | `users` | `id` |
