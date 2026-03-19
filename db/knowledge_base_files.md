# knowledge_base_files

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `knowledge_base_id` | `text` | NO |  | PK, FK → knowledge_bases.id |  |
| `file_id` | `text` | NO |  | PK, FK → files.id |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `user_id` | `text` | NO |  | FK → users.id |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `file_id` | `files` | `id` |
| `knowledge_base_id` | `knowledge_bases` | `id` |
| `user_id` | `users` | `id` |
