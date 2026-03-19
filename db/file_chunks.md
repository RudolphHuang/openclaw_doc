# file_chunks

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `file_id` | `character varying` | NO |  | PK, FK → files.id | 关联的文件ID |
| `chunk_id` | `uuid` | NO |  | PK, FK → chunks.id | 关联的分块ID |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `chunk_id` | `chunks` | `id` |
| `file_id` | `files` | `id` |
| `user_id` | `users` | `id` |
