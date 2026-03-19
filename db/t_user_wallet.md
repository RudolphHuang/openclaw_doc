# t_user_wallet

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `bigint` | NO |  | PK | 自增主键 |
| `user_id` | `character varying(128)` | NO |  |  | 用户ID |
| `chain` | `character varying(16)` | NO |  |  | 区块链网络，如 `tron`/`bnb` |
| `address` | `character varying(64)` | NO |  |  | 链上钱包地址（保持原始格式，TRON大小写敏感，BNB支持EIP-55格式） |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |

## 索引

| 索引名 | 定义 |
|--------|------|
| `idx_user_wallet_address_chain_unique` | `CREATE UNIQUE INDEX idx_user_wallet_address_chain_unique ON public.t_user_wallet USING btree (address, chain)` |
| `idx_user_wallet_user_chain_unique` | `CREATE UNIQUE INDEX idx_user_wallet_user_chain_unique ON public.t_user_wallet USING btree (user_id, chain)` |
