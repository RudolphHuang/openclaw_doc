# generation_batches

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK |  |
| `user_id` | `text` | NO |  | FK → users.id |  |
| `generation_topic_id` | `text` | NO |  | FK → generation_topics.id |  |
| `provider` | `text` | NO |  |  |  |
| `model` | `text` | NO |  |  |  |
| `prompt` | `text` | NO |  |  |  |
| `width` | `integer` | YES |  |  |  |
| `height` | `integer` | YES |  |  |  |
| `ratio` | `character varying(64)` | YES |  |  |  |
| `config` | `jsonb` | YES |  |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `generation_topic_id` | `generation_topics` | `id` |
| `user_id` | `users` | `id` |
