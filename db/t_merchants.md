# t_merchants

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `integer` | NO |  | PK |  |
| `merchant_id` | `character varying(16)` | NO |  | UQ |  |
| `name` | `character varying(64)` | NO |  |  |  |
| `enabled` | `boolean` | YES | true |  |  |
| `last_used_at` | `timestamp with time zone` | YES |  |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |

## 索引

| 索引名 | 定义 |
|--------|------|
| `idx_merchants_merchant_id` | `CREATE INDEX idx_merchants_merchant_id ON public.t_merchants USING btree (merchant_id)` |
| `t_merchants_merchant_id_unique` | `CREATE UNIQUE INDEX t_merchants_merchant_id_unique ON public.t_merchants USING btree (merchant_id)` |
