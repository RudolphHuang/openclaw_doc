# nextauth_authenticators

## 字段说明

| 字段名 | 类型 | 可空 | 默认值 | 约束 | 说明 |
|--------|------|------|--------|------|------|
| `counter` | `integer` | NO |  |  | WebAuthn认证器使用计数（防重放攻击） |
| `credentialBackedUp` | `boolean` | NO |  |  | 凭证是否已备份 |
| `credentialDeviceType` | `text` | NO |  |  | 认证器设备类型（single/multi-device） |
| `credentialID` | `text` | NO |  | PK, UQ | WebAuthn凭证唯一标识 |
| `credentialPublicKey` | `text` | NO |  |  | 公钥（CBOR格式） |
| `providerAccountId` | `text` | NO |  |  | 关联的OAuth账号ID |
| `transports` | `text` | YES |  |  | 支持的传输方式（usb/nfc/ble等） |
| `userId` | `text` | NO |  | PK, FK → users.id | 关联的用户ID |

## 外键关系

| 字段 | 引用表 | 引用字段 |
|------|--------|----------|
| `userId` | `users` | `id` |

## 索引

| 索引名 | 定义 |
|--------|------|
| `nextauth_authenticators_credentialID_unique` | `CREATE UNIQUE INDEX "nextauth_authenticators_credentialID_unique" ON public.nextauth_authenticators USING btree ("credentialID")` |
