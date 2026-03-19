# ai_providers

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `character varying(64)` | NO |  | PK | 提供商标识符，如 `openai`/`anthropic` |
| `name` | `text` | YES |  |  | 提供商显示名称 |
| `user_id` | `text` | NO |  | PK, FK → users.id | 所属用户ID |
| `sort` | `integer` | YES |  |  | 排序权重 |
| `enabled` | `boolean` | YES |  |  | 是否启用 |
| `fetch_on_client` | `boolean` | YES |  |  | 是否在客户端直接调用（不走服务端代理） |
| `check_model` | `text` | YES |  |  | 用于检测连通性的模型ID |
| `logo` | `text` | YES |  |  | 提供商Logo URL |
| `description` | `text` | YES |  |  | 提供商描述 |
| `key_vaults` | `text` | YES |  |  | 加密存储的API Key等凭证（AES加密文本） |
| `source` | `character varying(20)` | YES |  |  | 来源：`builtin`内置/`custom`自定义 |
| `settings` | `jsonb` | YES |  |  | 提供商配置（AiProviderSettings类型），JSON |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `config` | `jsonb` | YES |  |  | 提供商额外配置（AiProviderConfig类型），JSON |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |
