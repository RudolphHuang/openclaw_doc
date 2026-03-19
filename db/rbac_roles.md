# rbac_roles

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `integer` | NO |  | PK |  |
| `name` | `text` | NO |  | UQ |  |
| `display_name` | `text` | NO |  |  |  |
| `description` | `text` | YES |  |  |  |
| `is_system` | `boolean` | NO | false |  |  |
| `is_active` | `boolean` | NO | true |  |  |
| `accessed_at` | `timestamp with time zone` | NO | now() |  |  |
| `created_at` | `timestamp with time zone` | NO | now() |  |  |
| `updated_at` | `timestamp with time zone` | NO | now() |  |  |
| `metadata` | `jsonb` | YES | '{}'::jsonb |  |  |

## 索引

| 索引名 | 定义 |
|--------|------|
| `rbac_roles_name_unique` | `CREATE UNIQUE INDEX rbac_roles_name_unique ON public.rbac_roles USING btree (name)` |
