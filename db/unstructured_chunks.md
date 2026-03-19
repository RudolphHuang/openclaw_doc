# unstructured_chunks

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `uuid` | NO | gen_random_uuid() | PK | UUID主键 |
| `text` | `text` | YES |  |  | 非结构化分块文本内容 |
| `metadata` | `jsonb` | YES |  |  | 分块元数据，JSON |
| `index` | `integer` | YES |  |  | 块序号 |
| `type` | `character varying` | YES |  |  | 块类型（Title/NarrativeText/Table等非结构化类型） |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `parent_id` | `character varying` | YES |  |  | 父块ID（用于非结构化文档的层级关系） |
| `composite_id` | `uuid` | YES |  | FK → chunks.id | 关联的标准chunks表ID（复合关联） |
| `user_id` | `text` | YES |  | FK → users.id | 所属用户ID |
| `file_id` | `character varying` | YES |  | FK → files.id | 关联的文件ID |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `client_id` | `text` | YES |  |  | 客户端本地ID |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `composite_id` | `chunks` | `id` |
| `file_id` | `files` | `id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `unstructured_chunks_client_id_user_id_unique` | `CREATE UNIQUE INDEX unstructured_chunks_client_id_user_id_unique ON public.unstructured_chunks USING btree (client_id, user_id)` |
