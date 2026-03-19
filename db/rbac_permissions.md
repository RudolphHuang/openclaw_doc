# rbac_permissions

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `integer` | NO |  | PK |  |
| `code` | `text` | NO |  | UQ |  |
| `name` | `text` | NO |  |  |  |
| `description` | `text` | YES |  |  |  |
| `category` | `text` | NO |  |  |  |
| `is_active` | `boolean` | NO | true |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |

## 索引

| 索引名 | 定义 |
|--------|------|
| `rbac_permissions_code_unique` | `CREATE UNIQUE INDEX rbac_permissions_code_unique ON public.rbac_permissions USING btree (code)` |
