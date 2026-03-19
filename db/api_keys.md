# api_keys

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `integer` | NO |  | PK | 自增主键 |
| `name` | `character varying(256)` | NO |  |  | API Key名称（用户自定义） |
| `key` | `character varying(256)` | NO |  | UQ | API Key值（AES-GCM加密存储） |
| `enabled` | `boolean` | YES | true |  | 是否启用 |
| `expires_at` | `timestamp with time zone` | YES |  |  | 过期时间，null表示永不过期 |
| `last_used_at` | `timestamp with time zone` | YES |  |  | 最近使用时间 |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `key_hash` | `character varying(64)` | YES |  |  | Key的SHA-256哈希，用于O(1)快速查找 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `api_keys_key_unique` | `CREATE UNIQUE INDEX api_keys_key_unique ON public.api_keys USING btree (key)` |
