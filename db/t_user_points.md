# t_user_points

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `user_id` | `character varying(64)` | NO |  | PK, FK → users.id | 用户ID（主键） |
| `balance` | `bigint` | NO | 0 |  | 当前积分余额 |
| `updated_at` | `timestamp without time zone` | NO | now() |  | 最近更新时间 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `idx_user_points_user_id` | `CREATE INDEX idx_user_points_user_id ON public.t_user_points USING btree (user_id)` |
