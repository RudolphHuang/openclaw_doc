# knowledge_bases

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK | 知识库ID，格式 `kb_xxx` |
| `name` | `text` | NO |  |  | 知识库名称 |
| `description` | `text` | YES |  |  | 知识库描述 |
| `avatar` | `text` | YES |  |  | 知识库头像 |
| `type` | `text` | YES |  |  | 知识库类型，区分不同用途 |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `is_public` | `boolean` | YES | false |  | 是否公开（其他用户可访问） |
| `settings` | `jsonb` | YES |  |  | 知识库配置，JSON |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `client_id` | `text` | YES |  |  | 客户端本地ID |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `knowledge_bases_client_id_user_id_unique` | `CREATE UNIQUE INDEX knowledge_bases_client_id_user_id_unique ON public.knowledge_bases USING btree (client_id, user_id)` |
