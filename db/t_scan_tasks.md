# t_scan_tasks

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `bigint` | NO |  | PK |  |
| `chain` | `character varying(16)` | NO |  |  |  |
| `last_block_timestamp` | `bigint` | NO |  |  |  |
| `updated_at` | `timestamp without time zone` | NO | now() |  |  |

## 索引

| 索引名 | 定义 |
|--------|------|
| `idx_scan_tasks_chain` | `CREATE UNIQUE INDEX idx_scan_tasks_chain ON public.t_scan_tasks USING btree (chain)` |
