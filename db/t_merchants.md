# t_merchants

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `integer` | NO |  | PK | 自增主键 |
| `merchant_id` | `character varying(16)` | NO |  | UQ | 商户唯一标识（16字符） |
| `name` | `character varying(64)` | NO |  |  | 商户名称 |
| `enabled` | `boolean` | YES | true |  | 是否启用 |
| `last_used_at` | `timestamp with time zone` | YES |  |  | 最近使用时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |

## 索引

| 索引名 | 定义 |
|--------|------|
| `idx_merchants_merchant_id` | `CREATE INDEX idx_merchants_merchant_id ON public.t_merchants USING btree (merchant_id)` |
| `t_merchants_merchant_id_unique` | `CREATE UNIQUE INDEX t_merchants_merchant_id_unique ON public.t_merchants USING btree (merchant_id)` |
