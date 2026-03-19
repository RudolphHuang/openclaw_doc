# message_tts

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK, FK → messages.id | 与 messages.id 相同（1:1关系扩展表） |
| `content_md5` | `text` | YES |  |  | 消息内容的MD5（用于缓存判断） |
| `file_id` | `text` | YES |  | FK → files.id | 生成的音频文件ID |
| `voice` | `text` | YES |  |  | 使用的TTS语音标识 |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `client_id` | `text` | YES |  |  | 客户端本地ID |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `file_id` | `files` | `id` |
| `id` | `messages` | `id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `message_tts_client_id_user_id_unique` | `CREATE UNIQUE INDEX message_tts_client_id_user_id_unique ON public.message_tts USING btree (client_id, user_id)` |
