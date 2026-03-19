# user_installed_plugins

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `user_id` | `text` | NO |  | PK, FK → users.id | 用户ID |
| `identifier` | `text` | NO |  | PK | 插件唯一标识符 |
| `type` | `text` | NO |  |  | 插件类型：`plugin`/`customPlugin` |
| `manifest` | `jsonb` | YES |  |  | 插件清单（LobeChatPluginManifest类型），JSON |
| `settings` | `jsonb` | YES |  |  | 插件配置，JSON |
| `custom_params` | `jsonb` | YES |  |  | 自定义插件参数（CustomPluginParams类型），JSON |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |
