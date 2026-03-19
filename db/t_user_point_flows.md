# t_user_point_flows

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `integer` | NO |  | PK | 自增主键 |
| `user_id` | `character varying(64)` | NO |  | FK → users.id | 用户ID |
| `amount` | `bigint` | NO |  |  | 积分变动量（正数为入账，负数为消耗） |
| `source_type` | `character varying(32)` | NO |  |  | 积分来源类型，如 `api`/`web`/`recharge` |
| `source_id` | `character varying(128)` | YES |  |  | 来源记录ID（如消息ID、充值记录ID） |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `metadata` | `jsonb` | YES |  |  | 额外元数据，JSON |
| `total_input_tokens` | `integer` | NO | 0 |  | 输入Token总数 |
| `total_output_tokens` | `integer` | NO | 0 |  | 输出Token总数 |
| `total_tokens` | `integer` | YES | 0 |  | 总Token数 |
| `duration` | `integer` | YES | 0 |  | 请求耗时（毫秒） |
| `model` | `text` | YES |  |  | 消耗积分对应的模型名称 |
| `provider` | `text` | YES |  |  | 消耗积分对应的提供商 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `after_balance` | `bigint` | YES |  |  | 变动后余额 |
| `before_balance` | `bigint` | YES |  |  | 变动前余额 |
| `should_amount` | `bigint` | YES |  |  | 理论应扣积分（用于对账，与amount可能有差异） |
| `request_id` | `character varying(64)` | YES |  |  | 请求链路ID（用于扣费追踪排障） |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `idx_user_point_flows_created_at` | `CREATE INDEX idx_user_point_flows_created_at ON public.t_user_point_flows USING btree (created_at)` |
| `idx_user_point_flows_source_type` | `CREATE INDEX idx_user_point_flows_source_type ON public.t_user_point_flows USING btree (source_type)` |
| `idx_user_point_flows_user_amount_created_at` | `CREATE INDEX idx_user_point_flows_user_amount_created_at ON public.t_user_point_flows USING btree (user_id, amount, created_at)` |
| `idx_user_point_flows_user_request_id` | `CREATE INDEX idx_user_point_flows_user_request_id ON public.t_user_point_flows USING btree (user_id, request_id)` |
| `idx_user_point_flows_user_source_unique` | `CREATE UNIQUE INDEX idx_user_point_flows_user_source_unique ON public.t_user_point_flows USING btree (user_id, source_type, source_id)` |
