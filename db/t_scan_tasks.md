# t_scan_tasks

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `bigint` | NO |  | PK | 自增bigint主键 |
| `chain` | `character varying(16)` | NO |  |  | 扫链任务对应的区块链网络（唯一） |
| `last_block_timestamp` | `bigint` | NO |  |  | 上次扫描到的最新区块时间戳（Unix毫秒） |
| `updated_at` | `timestamp without time zone` | NO | now() |  | 任务状态更新时间 |

## 索引

| 索引名 | 定义 |
|--------|------|
| `idx_scan_tasks_chain` | `CREATE UNIQUE INDEX idx_scan_tasks_chain ON public.t_scan_tasks USING btree (chain)` |
