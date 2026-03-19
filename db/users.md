# users

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK | 用户唯一ID（由认证系统分配，如Clerk/NextAuth） |
| `username` | `text` | YES |  | UQ | 用户名（唯一） |
| `email` | `text` | YES |  |  | 邮箱地址 |
| `avatar` | `text` | YES |  |  | 头像URL |
| `phone` | `text` | YES |  |  | 手机号 |
| `first_name` | `text` | YES |  |  | 名 |
| `last_name` | `text` | YES |  |  | 姓 |
| `is_onboarded` | `boolean` | YES | false |  | 是否已完成新手引导 |
| `clerk_created_at` | `timestamp with time zone` | YES |  |  | 用户在Clerk系统的创建时间 |
| `preference` | `jsonb` | YES |  |  | 用户偏好设置（DEFAULT_PREFERENCE类型），JSON |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `full_name` | `text` | YES |  |  | 全名 |
| `email_verified_at` | `timestamp with time zone` | YES |  |  | 邮箱验证时间（NextAuth需要） |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `utm_source` | `character varying(255)` | YES |  |  | UTM来源参数（PostHog营销分析） |
| `utm_medium` | `character varying(255)` | YES |  |  | UTM媒介参数 |
| `utm_campaign` | `character varying(255)` | YES |  |  | UTM活动参数 |

## 索引

| 索引名 | 定义 |
|--------|------|
| `users_username_unique` | `CREATE UNIQUE INDEX users_username_unique ON public.users USING btree (username)` |
