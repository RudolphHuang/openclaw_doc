# rbac_roles

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `id` | `integer` | NO |  | PK | 角色ID（自增） |
| `name` | `text` | NO |  | UQ | 角色名称（唯一），如 `admin`/`user`/`guest` |
| `display_name` | `text` | NO |  |  | 角色显示名 |
| `description` | `text` | YES |  |  | 角色描述 |
| `is_system` | `boolean` | NO | false |  | 是否为系统内置角色（不可删除） |
| `is_active` | `boolean` | NO | true |  | 是否启用 |
| `accessed_at` | `timestamp with time zone` | NO | now() |  | 最近访问时间 |
| `created_at` | `timestamp with time zone` | NO | now() |  | 创建时间 |
| `updated_at` | `timestamp with time zone` | NO | now() |  | 最近更新时间 |
| `metadata` | `jsonb` | YES | '{}'::jsonb |  | 角色扩展元数据，JSON |

## 索引

| 索引名 | 定义 |
|--------|------|
| `rbac_roles_name_unique` | `CREATE UNIQUE INDEX rbac_roles_name_unique ON public.rbac_roles USING btree (name)` |
