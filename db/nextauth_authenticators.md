# nextauth_authenticators

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `counter` | `integer` | NO |  |  |  |
| `credentialBackedUp` | `boolean` | NO |  |  |  |
| `credentialDeviceType` | `text` | NO |  |  |  |
| `credentialID` | `text` | NO |  | PK, UQ |  |
| `credentialPublicKey` | `text` | NO |  |  |  |
| `providerAccountId` | `text` | NO |  |  |  |
| `transports` | `text` | YES |  |  |  |
| `userId` | `text` | NO |  | PK, FK → users.id |  |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `userId` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `nextauth_authenticators_credentialID_unique` | `CREATE UNIQUE INDEX "nextauth_authenticators_credentialID_unique" ON public.nextauth_authenticators USING btree ("credentialID")` |
