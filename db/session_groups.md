# session_groups

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK | 会话分组ID，格式 `sgrp_xxx` |
| `name` | `text` | NO |  |  | 分组名称 |
| `sort` | `integer` | YES |  |  | 排序权重 |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `client_id` | `text` | YES |  |  | 客户端本地ID |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `session_groups_client_id_user_id_unique` | `CREATE UNIQUE INDEX session_groups_client_id_user_id_unique ON public.session_groups USING btree (client_id, user_id)` |
