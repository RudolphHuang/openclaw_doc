# chat_groups

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK | 多Agent聊天组ID，格式 `cgrp_xxx` |
| `title` | `text` | YES |  |  | 聊天组标题 |
| `description` | `text` | YES |  |  | 聊天组描述 |
| `config` | `jsonb` | YES |  |  | 聊天组配置（ChatGroupConfig类型），JSON |
| `client_id` | `text` | YES |  |  | 客户端本地ID，用于多端同步 |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `pinned` | `boolean` | YES | false |  | 是否置顶 |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `group_id` | `text` | YES |  | FK → session_groups.id | 所属会话分组ID（session_groups） |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `group_id` | `session_groups` | `id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `chat_groups_client_id_user_id_unique` | `CREATE UNIQUE INDEX chat_groups_client_id_user_id_unique ON public.chat_groups USING btree (client_id, user_id)` |
