# 获取当前会话接口

获取当前用户的会话信息，包括用户基本信息和会话过期时间。

## GET /api/auth/session

**接口说明**: 获取当前登录用户的会话信息。

**请求方法**: `GET`

**权限**: 需要认证（通过 Cookie 中的 session token）

---

### 请求头

| 头部 | 必填 | 说明 |
|------|------|------|
| `Cookie` | 是 | 包含 `__Secure-authjs.session-token` 等认证 Cookie |
| `Accept` | 否 | 接受的数据格式，如 `application/json` |

---

### 请求示例

```bash
curl 'https://chat-dev.ainft.com/api/auth/session' \
  -H 'accept: application/json' \
  -H 'x-ainft-chat-auth: YOUR_AUTH_TOKEN' \
  -b '__Secure-authjs.session-token=YOUR_SESSION_TOKEN'
```

---

### 响应数据

| 字段 | 类型 | 说明 |
|------|------|------|
| `user` | object | 用户信息对象 |
| `user.id` | string | 用户唯一标识（Tron 钱包地址） |
| `user.name` | string \| null | 用户显示名称 |
| `user.email` | string \| null | 用户邮箱 |
| `user.image` | string \| null | 用户头像 URL |
| `expires` | string | 会话过期时间（ISO 8601 格式） |

---

### 响应示例

```json
{
  "user": {
    "name": "TRON TMujsbV6t2weXmoPrdfc8QAMJ3oZCJFBXo",
    "email": null,
    "image": null,
    "id": "TMujsbV6t2weXmoPrdfc8QAMJ3oZCJFBXo"
  },
  "expires": "2026-03-26T05:52:45.879Z"
}
```

---

### 说明

- 此接口用于验证当前用户是否已登录并获取基本信息
- 如果用户未登录或会话已过期，可能返回空对象或错误
- `user.id` 对于 TronLink 登录用户，即为 Tron 钱包地址
- `expires` 表示会话过期时间，过期后需要重新登录

---

### 错误响应

| 状态码 | 说明 |
|--------|------|
| `401` | 未认证，用户未登录或会话已过期 |

---

### 相关接口

- [Clerk 认证](auth-clerk.md) - 邮箱、手机号、OAuth 登录
- [TronLink 登录](auth-tronlink.md) - TronLink 钱包登录接口
- [登出接口](auth-signout.md) - 用户登出
