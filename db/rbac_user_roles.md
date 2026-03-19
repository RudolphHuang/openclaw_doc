# rbac_user_roles

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `user_id` | `text` | NO |  | PK, FK → users.id | 用户ID |
| `role_id` | `integer` | NO |  | PK, FK → rbac_roles.id | 角色ID |
| `created_at` | `timestamp with time zone` | NO | now() |  | 关联创建时间 |
| `expires_at` | `timestamp with time zone` | YES |  |  | 角色有效期（null表示永久，支持临时角色） |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `role_id` | `rbac_roles` | `id` |
| `user_id` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `rbac_user_roles_role_id_idx` | `CREATE INDEX rbac_user_roles_role_id_idx ON public.rbac_user_roles USING btree (role_id)` |
| `rbac_user_roles_user_id_idx` | `CREATE INDEX rbac_user_roles_user_id_idx ON public.rbac_user_roles USING btree (user_id)` |
