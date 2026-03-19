# global_files

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `hash_id` | `character varying(64)` | NO |  | PK | 文件SHA-256哈希，作为主键（全局去重） |
| `file_type` | `character varying(255)` | NO |  |  | 文件MIME类型 |
| `size` | `integer` | NO |  |  | 文件大小（字节） |
| `url` | `text` | NO |  |  | 文件实际存储URL |
| `metadata` | `jsonb` | YES |  |  | 文件元数据，JSON |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `creator` | `text` | YES |  | FK → users.id | 首次上传该文件的用户ID |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `creator` | `users` | `id` |
