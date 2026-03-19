# oauth_handoffs

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `text` | NO |  | PK | 客户端生成的一次性唯一标识，用于轮询认领 |
| `client` | `character varying(50)` | NO |  |  | 客户端类型，如 `desktop`/`browser-extension`/`mobile-app` |
| `payload` | `jsonb` | NO |  |  | 凭证数据载荷（含code和state），JSON |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
