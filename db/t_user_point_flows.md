# t_user_point_flows

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `integer` | NO |  | PK |  |
| `user_id` | `character varying(64)` | NO |  | FK → users.id |  |
| `amount` | `bigint` | NO |  |  |  |
| `source_type` | `character varying(32)` | NO |  |  |  |
| `source_id` | `character varying(128)` | YES |  |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `metadata` | `jsonb` | YES |  |  |  |
| `total_input_tokens` | `integer` | NO | 0 |  |  |
| `total_output_tokens` | `integer` | NO | 0 |  |  |
| `total_tokens` | `integer` | YES | 0 |  |  |
| `duration` | `integer` | YES | 0 |  |  |
| `model` | `text` | YES |  |  |  |
| `provider` | `text` | YES |  |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `after_balance` | `bigint` | YES |  |  |  |
| `before_balance` | `bigint` | YES |  |  |  |
| `should_amount` | `bigint` | YES |  |  |  |
| `request_id` | `character varying(64)` | YES |  |  |  |

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
