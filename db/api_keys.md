# api_keys

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `integer` | NO |  | PK |  |
| `name` | `character varying(256)` | NO |  |  |  |
| `key` | `character varying(256)` | NO |  | UQ |  |
| `enabled` | `boolean` | YES | true |  |  |
| `expires_at` | `timestamp with time zone` | YES |  |  |  |
| `last_used_at` | `timestamp with time zone` | YES |  |  |  |
| `user_id` | `text` | NO |  | FK → users.id |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `key_hash` | `character varying(64)` | YES |  |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `api_keys_key_unique` | `CREATE UNIQUE INDEX api_keys_key_unique ON public.api_keys USING btree (key)` |
