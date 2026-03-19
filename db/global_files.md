# global_files

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `hash_id` | `character varying(64)` | NO |  | PK |  |
| `file_type` | `character varying(255)` | NO |  |  |  |
| `size` | `integer` | NO |  |  |  |
| `url` | `text` | NO |  |  |  |
| `metadata` | `jsonb` | YES |  |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `creator` | `text` | YES |  | FK → users.id |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `creator` | `users` | `id` |
