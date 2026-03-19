# ai_models

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `character varying(150)` | NO |  | PK | 模型标识符，如 `gpt-4o` |
| `display_name` | `character varying(200)` | YES |  |  | 模型显示名称 |
| `description` | `text` | YES |  |  | 模型描述 |
| `organization` | `character varying(100)` | YES |  |  | 模型所属组织，如 OpenAI |
| `enabled` | `boolean` | YES |  |  | 是否对该用户启用 |
| `provider_id` | `character varying(64)` | NO |  | PK | 所属提供商ID，如 `openai` |
| `type` | `character varying(20)` | NO | 'chat'::character varying |  | 模型类型，枚举：`chat`/`tts`/`stt`/`embedding`/`text2img` |
| `sort` | `integer` | YES |  |  | 排序权重 |
| `user_id` | `text` | NO |  | PK, FK → users.id | 所属用户ID（每个用户有独立的模型配置） |
| `pricing` | `jsonb` | YES |  |  | 模型定价信息，JSON |
| `parameters` | `jsonb` | YES | '{}'::jsonb |  | 模型支持的参数配置，JSON |
| `config` | `jsonb` | YES |  |  | 模型额外配置，JSON |
| `abilities` | `jsonb` | YES | '{}'::jsonb |  | 模型能力标记（vision/functionCall等），JSON |
| `context_window_tokens` | `integer` | YES |  |  | 模型上下文窗口大小（Token数） |
| `source` | `character varying(20)` | YES |  |  | 来源：`builtin`内置/`custom`自定义/`remote`远程拉取 |
| `released_at` | `character varying(10)` | YES |  |  | 模型发布日期，格式 YYYY-MM-DD |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |
