# t_recharge_records

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `bigint` | NO |  | PK |  |
| `user_id` | `character varying(64)` | NO |  | FK → users.id |  |
| `user_address` | `character varying(64)` | NO |  |  |  |
| `receiver_address` | `character varying(64)` | NO |  |  |  |
| `chain` | `character varying(16)` | NO |  |  |  |
| `token_name` | `character varying(16)` | NO |  |  |  |
| `amount` | `bigint` | NO |  |  |  |
| `usd_amount` | `integer` | YES |  |  |  |
| `tx_hash` | `character varying(128)` | NO |  |  |  |
| `block_number` | `bigint` | NO |  |  |  |
| `confirmed_at` | `timestamp without time zone` | YES |  |  |  |
| `created_at` | `timestamp without time zone` | NO | now() |  |  |
| `merchant_id` | `character varying(64)` | YES |  |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `idx_recharge_records_tx_hash` | `CREATE INDEX idx_recharge_records_tx_hash ON public.t_recharge_records USING btree (tx_hash)` |
| `idx_recharge_records_user_address` | `CREATE INDEX idx_recharge_records_user_address ON public.t_recharge_records USING btree (user_address)` |
| `idx_recharge_records_user_id` | `CREATE INDEX idx_recharge_records_user_id ON public.t_recharge_records USING btree (user_id)` |
