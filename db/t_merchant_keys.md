# t_merchant_keys

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `integer` | NO |  | PK | 自增主键 |
| `merchant_id` | `character varying(16)` | NO |  |  | 商户ID，关联t_merchants |
| `merchant_key` | `character varying(64)` | NO |  |  | 商户密钥值 |
| `status` | `character varying(20)` | NO | 'active'::character varying |  | 密钥状态：`active`/`revoked` |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |

## 索引

| 索引名 | 定义 |
|--------|------|
| `idx_merchant_keys_merchant_id_status` | `CREATE INDEX idx_merchant_keys_merchant_id_status ON public.t_merchant_keys USING btree (merchant_id, status)` |
