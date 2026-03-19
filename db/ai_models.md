# ai_models

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `character varying(150)` | NO |  | PK |  |
| `display_name` | `character varying(200)` | YES |  |  |  |
| `description` | `text` | YES |  |  |  |
| `organization` | `character varying(100)` | YES |  |  |  |
| `enabled` | `boolean` | YES |  |  |  |
| `provider_id` | `character varying(64)` | NO |  | PK |  |
| `type` | `character varying(20)` | NO | 'chat'::character varying |  |  |
| `sort` | `integer` | YES |  |  |  |
| `user_id` | `text` | NO |  | PK, FK → users.id |  |
| `pricing` | `jsonb` | YES |  |  |  |
| `parameters` | `jsonb` | YES | '{}'::jsonb |  |  |
| `config` | `jsonb` | YES |  |  |  |
| `abilities` | `jsonb` | YES | '{}'::jsonb |  |  |
| `context_window_tokens` | `integer` | YES |  |  |  |
| `source` | `character varying(20)` | YES |  |  |  |
| `released_at` | `character varying(10)` | YES |  |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |
