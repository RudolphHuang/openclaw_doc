# t_user_wallet

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `bigint` | NO |  | PK |  |
| `user_id` | `character varying(128)` | NO |  |  |  |
| `chain` | `character varying(16)` | NO |  |  |  |
| `address` | `character varying(64)` | NO |  |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |

## 索引

| 索引名 | 定义 |
|--------|------|
| `idx_user_wallet_address_chain_unique` | `CREATE UNIQUE INDEX idx_user_wallet_address_chain_unique ON public.t_user_wallet USING btree (address, chain)` |
| `idx_user_wallet_user_chain_unique` | `CREATE UNIQUE INDEX idx_user_wallet_user_chain_unique ON public.t_user_wallet USING btree (user_id, chain)` |
