# oidc_clients

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `character varying(255)` | NO |  | PK | OIDC客户端ID（即client_id） |
| `name` | `text` | NO |  |  | 客户端名称 |
| `description` | `text` | YES |  |  | 客户端描述 |
| `client_secret` | `character varying(255)` | YES |  |  | 客户端密钥（公共客户端为null） |
| `redirect_uris` | `ARRAY` | NO |  |  | 允许的重定向URI列表，数组 |
| `grants` | `ARRAY` | NO |  |  | 支持的授权类型（authorization_code等），数组 |
| `response_types` | `ARRAY` | NO |  |  | 支持的响应类型，数组 |
| `scopes` | `ARRAY` | NO |  |  | 支持的权限范围，数组 |
| `token_endpoint_auth_method` | `character varying(20)` | YES |  |  | 令牌端点认证方式 |
| `application_type` | `character varying(20)` | YES |  |  | 应用类型（web/native） |
| `client_uri` | `text` | YES |  |  | 客户端主页URL |
| `logo_uri` | `text` | YES |  |  | 客户端Logo URL |
| `policy_uri` | `text` | YES |  |  | 隐私政策URL |
| `tos_uri` | `text` | YES |  |  | 服务条款URL |
| `is_first_party` | `boolean` | YES | false |  | 是否为第一方应用（信任应用） |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
