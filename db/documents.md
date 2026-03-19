# documents

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `character varying(30)` | NO |  | PK | 文档ID，格式 `doc_xxx`（16字符） |
| `title` | `text` | YES |  |  | 文档标题 |
| `content` | `text` | YES |  |  | 文档全文内容 |
| `file_type` | `character varying(255)` | NO |  |  | 文档MIME类型 |
| `filename` | `text` | YES |  |  | 原始文件名 |
| `total_char_count` | `integer` | NO |  |  | 文档总字符数 |
| `total_line_count` | `integer` | NO |  |  | 文档总行数 |
| `metadata` | `jsonb` | YES |  |  | 文档元数据，JSON |
| `pages` | `jsonb` | YES |  |  | 文档分页数据（LobeDocumentPage[]类型），JSON |
| `source_type` | `text` | NO |  |  | 来源类型：`file`/`web`/`api` |
| `source` | `text` | NO |  |  | 来源路径或URL |
| `file_id` | `text` | YES |  | FK → files.id | 关联的原始文件ID（可为空） |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `client_id` | `text` | YES |  |  | 客户端本地ID |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `editor_data` | `jsonb` | YES |  |  | 富文本编辑器数据，JSON |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `file_id` | `files` | `id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `documents_client_id_user_id_unique` | `CREATE UNIQUE INDEX documents_client_id_user_id_unique ON public.documents USING btree (client_id, user_id)` |
| `documents_file_id_idx` | `CREATE INDEX documents_file_id_idx ON public.documents USING btree (file_id)` |
| `documents_file_type_idx` | `CREATE INDEX documents_file_type_idx ON public.documents USING btree (file_type)` |
| `documents_source_idx` | `CREATE INDEX documents_source_idx ON public.documents USING btree (source)` |
