# rbac_permissions

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `integer` | NO |  | PK | 权限ID（自增） |
| `code` | `text` | NO |  | UQ | 权限代码，如 `chat:create`/`file:upload`（唯一） |
| `name` | `text` | NO |  |  | 权限显示名称 |
| `description` | `text` | YES |  |  | 权限描述 |
| `category` | `text` | NO |  |  | 权限所属分类，如 `message`/`knowledge_base`/`agent` |
| `is_active` | `boolean` | NO | true |  | 是否启用 |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |

## 索引

| 索引名 | 定义 |
|--------|------|
| `rbac_permissions_code_unique` | `CREATE UNIQUE INDEX rbac_permissions_code_unique ON public.rbac_permissions USING btree (code)` |
