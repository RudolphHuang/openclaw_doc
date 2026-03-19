# t_merchant_keys

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `integer` | NO |  | PK |  |
| `merchant_id` | `character varying(16)` | NO |  |  |  |
| `merchant_key` | `character varying(64)` | NO |  |  |  |
| `status` | `character varying(20)` | NO | 'active'::character varying |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |

## 索引

| 索引名 | 定义 |
|--------|------|
| `idx_merchant_keys_merchant_id_status` | `CREATE INDEX idx_merchant_keys_merchant_id_status ON public.t_merchant_keys USING btree (merchant_id, status)` |
