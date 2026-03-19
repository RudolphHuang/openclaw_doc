# t_model_price

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `integer` | NO |  | PK |  |
| `provider` | `character varying(32)` | NO |  |  |  |
| `model_name` | `character varying(64)` | NO |  |  |  |
| `input_price` | `integer` | NO | 1 |  |  |
| `output_price` | `integer` | NO | 1 |  |  |
| `updated_at` | `timestamp with time zone` | YES | now() |  |  |

## 索引

| 索引名 | 定义 |
|--------|------|
| `t_model_price_provider_model_unique` | `CREATE UNIQUE INDEX t_model_price_provider_model_unique ON public.t_model_price USING btree (provider, model_name)` |
