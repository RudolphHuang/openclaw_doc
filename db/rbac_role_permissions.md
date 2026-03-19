# rbac_role_permissions

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `role_id` | `integer` | NO |  | PK, FK → rbac_roles.id | 角色ID |
| `permission_id` | `integer` | NO |  | PK, FK → rbac_permissions.id | 权限ID |
| `created_at` | `timestamp with time zone` | NO | now() |  | 关联创建时间 |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `permission_id` | `rbac_permissions` | `id` |
| `role_id` | `rbac_roles` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `rbac_role_permissions_permission_id_idx` | `CREATE INDEX rbac_role_permissions_permission_id_idx ON public.rbac_role_permissions USING btree (permission_id)` |
| `rbac_role_permissions_role_id_idx` | `CREATE INDEX rbac_role_permissions_role_id_idx ON public.rbac_role_permissions USING btree (role_id)` |
