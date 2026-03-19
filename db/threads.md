# threads

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK | 线程ID（16字符） |
| `title` | `text` | YES |  |  | 线程标题 |
| `type` | `text` | NO |  |  | 线程类型：`continuation`（延续型）/`standalone`（独立型） |
| `status` | `text` | YES | 'active'::text |  | 线程状态：`active`/`deprecated`/`archived` |
| `topic_id` | `text` | NO |  | FK → topics.id | 所属话题ID |
| `source_message_id` | `text` | NO |  |  | 触发该线程的消息ID（起点消息） |
| `parent_thread_id` | `text` | YES |  | FK → threads.id | 父线程ID（支持线程嵌套） |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `last_active_at` | `timestamp with time zone` | YES | now() |  | 最近活跃时间 |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `client_id` | `text` | YES |  |  | 客户端本地ID |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `parent_thread_id` | `threads` | `id` |
| `topic_id` | `topics` | `id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `threads_client_id_user_id_unique` | `CREATE UNIQUE INDEX threads_client_id_user_id_unique ON public.threads USING btree (client_id, user_id)` |
