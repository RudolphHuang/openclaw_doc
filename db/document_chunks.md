# document_chunks

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `document_id` | `character varying(30)` | NO |  | PK, FK → documents.id |  |
| `chunk_id` | `uuid` | NO |  | PK, FK → chunks.id |  |
| `page_index` | `integer` | YES |  |  |  |
| `user_id` | `text` | NO |  | FK → users.id |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `chunk_id` | `chunks` | `id` |
| `document_id` | `documents` | `id` |
| `user_id` | `users` | `id` |
