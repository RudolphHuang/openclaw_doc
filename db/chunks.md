# chunks

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `uuid` | NO | gen_random_uuid() | PK | UUID主键 |
| `text` | `text` | YES |  |  | 分块的原始文本内容 |
| `abstract` | `text` | YES |  |  | 分块内容的摘要/抽象描述 |
| `metadata` | `jsonb` | YES |  |  | 分块元数据（页码、来源等），JSON |
| `index` | `integer` | YES |  |  | 在原文档中的块序号 |
| `type` | `character varying` | YES |  |  | 分块类型（text/table/image等） |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `user_id` | `text` | YES |  | FK → users.id | 所属用户ID |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `client_id` | `text` | YES |  |  | 客户端本地ID |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `chunks_client_id_user_id_unique` | `CREATE UNIQUE INDEX chunks_client_id_user_id_unique ON public.chunks USING btree (client_id, user_id)` |
| `chunks_user_id_idx` | `CREATE INDEX chunks_user_id_idx ON public.chunks USING btree (user_id)` |
