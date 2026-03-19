# agents

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK | Agent唯一标识，格式为 `agn_xxx` |
| `slug` | `character varying(100)` | YES |  | UQ | Agent的URL友好标识符，随机生成4字符 |
| `title` | `character varying(255)` | YES |  |  | Agent名称/标题 |
| `description` | `character varying(1000)` | YES |  |  | Agent描述，最长1000字符 |
| `tags` | `jsonb` | YES | '[]'::jsonb |  | Agent标签列表，JSON数组 |
| `avatar` | `text` | YES |  |  | Agent头像URL或emoji |
| `background_color` | `text` | YES |  |  | Agent背景颜色 |
| `plugins` | `jsonb` | YES | '[]'::jsonb |  | 该Agent启用的插件标识列表，JSON数组 |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID，级联删除 |
| `chat_config` | `jsonb` | YES |  |  | Agent聊天配置（LobeAgentChatConfig类型），含压缩阈值等 |
| `few_shots` | `jsonb` | YES |  |  | 少样本示例，用于引导Agent对话 |
| `model` | `text` | YES |  |  | Agent使用的AI模型ID |
| `params` | `jsonb` | YES | '{}'::jsonb |  | 模型调用参数（temperature等），JSON对象 |
| `provider` | `text` | YES |  |  | AI提供商ID |
| `system_role` | `text` | YES |  |  | Agent系统提示词（System Prompt） |
| `tts` | `jsonb` | YES |  |  | 文字转语音配置（LobeAgentTTSConfig类型） |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `client_id` | `text` | YES |  |  | 客户端本地ID，用于多端同步去重 |
| `opening_message` | `text` | YES |  |  | Agent开场白消息 |
| `opening_questions` | `ARRAY` | YES | '{}'::text[] |  | Agent建议的开场问题列表 |
| `virtual` | `boolean` | YES | false |  | 是否为虚拟Agent（非用户创建，系统内置） |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `agents_description_idx` | `CREATE INDEX agents_description_idx ON public.agents USING btree (description)` |
| `agents_slug_unique` | `CREATE UNIQUE INDEX agents_slug_unique ON public.agents USING btree (slug)` |
| `agents_title_idx` | `CREATE INDEX agents_title_idx ON public.agents USING btree (title)` |
| `client_id_user_id_unique` | `CREATE UNIQUE INDEX client_id_user_id_unique ON public.agents USING btree (client_id, user_id)` |
