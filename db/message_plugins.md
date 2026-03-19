# message_plugins

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK, FK → messages.id | 与 messages.id 相同（1:1关系扩展表） |
| `tool_call_id` | `text` | YES |  |  | 工具调用ID（LLM返回的tool_call标识） |
| `type` | `text` | YES | 'default'::text |  | 插件类型：`default`/`markdown`/`standalone`/`builtin` |
| `api_name` | `text` | YES |  |  | 调用的API名称 |
| `arguments` | `text` | YES |  |  | 工具调用参数（JSON字符串） |
| `identifier` | `text` | YES |  |  | 插件标识符 |
| `state` | `jsonb` | YES |  |  | 插件执行状态，JSON |
| `error` | `jsonb` | YES |  |  | 插件执行错误信息，JSON |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `client_id` | `text` | YES |  |  | 客户端本地ID |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `id` | `messages` | `id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `message_plugins_client_id_user_id_unique` | `CREATE UNIQUE INDEX message_plugins_client_id_user_id_unique ON public.message_plugins USING btree (client_id, user_id)` |
