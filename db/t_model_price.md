# t_model_price

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `integer` | NO |  | PK | 自增主键 |
| `provider` | `character varying(32)` | NO |  |  | 提供商标识 |
| `model_name` | `character varying(64)` | NO |  |  | 模型名称 |
| `input_price` | `integer` | NO | 1 |  | 输入Token单价（积分/千Token） |
| `output_price` | `integer` | NO | 1 |  | 输出Token单价（积分/千Token） |
| `updated_at` | `timestamp with time zone` | YES | now() |  | 更新时间 |

## 索引

| 索引名 | 定义 |
|--------|------|
| `t_model_price_provider_model_unique` | `CREATE UNIQUE INDEX t_model_price_provider_model_unique ON public.t_model_price USING btree (provider, model_name)` |
