# user_settings

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK, FK → users.id |  |
| `tts` | `jsonb` | YES |  |  |  |
| `key_vaults` | `text` | YES |  |  |  |
| `general` | `jsonb` | YES |  |  |  |
| `language_model` | `jsonb` | YES |  |  |  |
| `system_agent` | `jsonb` | YES |  |  |  |
| `default_agent` | `jsonb` | YES |  |  |  |
| `tool` | `jsonb` | YES |  |  |  |
| `hotkey` | `jsonb` | YES |  |  |  |
| `image` | `jsonb` | YES |  |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `id` | `users` | `id` |
