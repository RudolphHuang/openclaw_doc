# t_signup_bonus_ip_limits

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `created_at` | `timestamp without time zone` | NO | now() |  | 记录创建时间（用于时间窗口限流） |
| `id` | `integer` | NO |  | PK | 自增主键 |
| `ip` | `character varying(64)` | NO |  |  | 注册来源IP地址 |

## 索引

| 索引名 | 定义 |
|--------|------|
| `idx_signup_bonus_ip_limits_ip_created_at` | `CREATE INDEX idx_signup_bonus_ip_limits_ip_created_at ON public.t_signup_bonus_ip_limits USING btree (ip, created_at)` |
