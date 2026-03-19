# generation_topics

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK | 图片生成主题ID |
| `user_id` | `text` | NO |  | FK → users.id | 所属用户ID |
| `title` | `text` | YES |  |  | 主题标题，由LLM根据内容生成 |
| `cover_url` | `text` | YES |  |  | 主题封面图URL |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `user_id` | `users` | `id` |
