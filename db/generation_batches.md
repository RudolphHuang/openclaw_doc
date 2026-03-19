# generation_batches

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK | 图片生成批次ID |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `generation_topic_id` | `text` | NO |  | FK → generation_topics.id | 所属生成主题ID |
| `provider` | `text` | NO |  |  | 图片生成服务商名称 |
| `model` | `text` | NO |  |  | 使用的图片生成模型 |
| `prompt` | `text` | NO |  |  | 图片生成提示词 |
| `width` | `integer` | YES |  |  | 生成图片宽度（像素） |
| `height` | `integer` | YES |  |  | 生成图片高度（像素） |
| `ratio` | `character varying(64)` | YES |  |  | 图片宽高比，如 `16:9` |
| `config` | `jsonb` | YES |  |  | 批次额外配置（不建索引的公共参数），JSON |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `generation_topic_id` | `generation_topics` | `id` |
| `user_id` | `users` | `id` |
