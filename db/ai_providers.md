# ai_providers

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `character varying(64)` | NO |  | PK |  |
| `name` | `text` | YES |  |  |  |
| `user_id` | `text` | NO |  | PK, FK → users.id |  |
| `sort` | `integer` | YES |  |  |  |
| `enabled` | `boolean` | YES |  |  |  |
| `fetch_on_client` | `boolean` | YES |  |  |  |
| `check_model` | `text` | YES |  |  |  |
| `logo` | `text` | YES |  |  |  |
| `description` | `text` | YES |  |  |  |
| `key_vaults` | `text` | YES |  |  |  |
| `source` | `character varying(20)` | YES |  |  |  |
| `settings` | `jsonb` | YES |  |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `config` | `jsonb` | YES |  |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |
