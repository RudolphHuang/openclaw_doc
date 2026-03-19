# agents_files

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `file_id` | `text` | NO |  | PK, FK → files.id | 关联的文件ID |
| `agent_id` | `text` | NO |  | PK, FK → agents.id | 关联的Agent ID |
| `enabled` | `boolean` | YES | true |  | 该文件在此Agent中是否启用 |
| `user_id` | `text` | NO |  | PK, FK → users.id | 所属用户ID |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `agent_id` | `agents` | `id` |
| `file_id` | `files` | `id` |
| `user_id` | `users` | `id` |
