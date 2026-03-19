# t_recharge_records

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `bigint` | NO |  | PK | 自增bigint主键 |
| `user_id` | `character varying(64)` | NO |  | FK → users.id | 关联的用户ID |
| `user_address` | `character varying(64)` | NO |  |  | 用户的链上钱包地址 |
| `receiver_address` | `character varying(64)` | NO |  |  | 接收方平台地址 |
| `chain` | `character varying(16)` | NO |  |  | 区块链网络标识，如 `tron`/`bnb` |
| `token_name` | `character varying(16)` | NO |  |  | 代币名称，如 `USDT` |
| `amount` | `bigint` | NO |  |  | 转账金额（最小单位，如USDT的6位精度） |
| `usd_amount` | `integer` | YES |  |  | 对应USD金额（整数，美分） |
| `tx_hash` | `character varying(128)` | NO |  |  | 链上交易哈希 |
| `block_number` | `bigint` | NO |  |  | 交易所在区块号 |
| `confirmed_at` | `timestamp without time zone` | YES |  |  | 链上确认时间 |
| `created_at` | `timestamp without time zone` | NO | now() |  | 记录创建时间 |
| `merchant_id` | `character varying(64)` | YES |  |  | WebAPI充值时关联的商户ID，非webapi或历史订单为null |

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
