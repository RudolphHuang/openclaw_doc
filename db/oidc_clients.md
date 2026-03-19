# oidc_clients

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `character varying(255)` | NO |  | PK |  |
| `name` | `text` | NO |  |  |  |
| `description` | `text` | YES |  |  |  |
| `client_secret` | `character varying(255)` | YES |  |  |  |
| `redirect_uris` | `ARRAY` | NO |  |  |  |
| `grants` | `ARRAY` | NO |  |  |  |
| `response_types` | `ARRAY` | NO |  |  |  |
| `scopes` | `ARRAY` | NO |  |  |  |
| `token_endpoint_auth_method` | `character varying(20)` | YES |  |  |  |
| `application_type` | `character varying(20)` | YES |  |  |  |
| `client_uri` | `text` | YES |  |  |  |
| `logo_uri` | `text` | YES |  |  |  |
| `policy_uri` | `text` | YES |  |  |  |
| `tos_uri` | `text` | YES |  |  |  |
| `is_first_party` | `boolean` | YES | false |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
