# chunks

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `uuid` | NO | gen_random_uuid() | PK |  |
| `text` | `text` | YES |  |  |  |
| `abstract` | `text` | YES |  |  |  |
| `metadata` | `jsonb` | YES |  |  |  |
| `index` | `integer` | YES |  |  |  |
| `type` | `character varying` | YES |  |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `user_id` | `text` | YES |  | FK → users.id |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `client_id` | `text` | YES |  |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `chunks_client_id_user_id_unique` | `CREATE UNIQUE INDEX chunks_client_id_user_id_unique ON public.chunks USING btree (client_id, user_id)` |
| `chunks_user_id_idx` | `CREATE INDEX chunks_user_id_idx ON public.chunks USING btree (user_id)` |
