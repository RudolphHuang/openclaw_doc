# user_settings

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK, FK → users.id | 用户ID（1:1关系，即 users.id） |
| `tts` | `jsonb` | YES |  |  | TTS（文字转语音）全局配置，JSON |
| `key_vaults` | `text` | YES |  |  | 用户自定义API Key加密存储（AES加密文本） |
| `general` | `jsonb` | YES |  |  | 通用设置（主题、语言等），JSON |
| `language_model` | `jsonb` | YES |  |  | 语言模型偏好配置，JSON |
| `system_agent` | `jsonb` | YES |  |  | 系统Agent配置，JSON |
| `default_agent` | `jsonb` | YES |  |  | 默认Agent配置，JSON |
| `tool` | `jsonb` | YES |  |  | 工具配置，JSON |
| `hotkey` | `jsonb` | YES |  |  | 快捷键配置，JSON |
| `image` | `jsonb` | YES |  |  | 图片生成相关配置，JSON |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `id` | `users` | `id` |
