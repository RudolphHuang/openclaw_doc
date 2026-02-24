# 登出接口

用户登出接口，用于清除会话并退出登录。

## POST /api/auth/signout

**接口说明**: 用户登出，清除当前会话。

**请求方法**: `POST`

**Content-Type**: `application/x-www-form-urlencoded`

---

### 请求头

| 头部 | 必填 | 说明 |
|------|------|------|
| `Cookie` | 是 | 包含 `__Host-authjs.csrf-token`、`__Secure-authjs.session-token` 等认证 Cookie |
| `Origin` | 是 | 请求来源，如 `https://chat-dev.ainft.com` |
| `Referer` | 是 | 来源页面 URL |
| `x-auth-return-redirect` | 否 | 是否返回重定向信息，如 `1` |

---

### 请求参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `csrfToken` | string | 是 | CSRF 令牌，从 Cookie `__Host-authjs.csrf-token` 中获取 |
| `callbackUrl` | string | 否 | 登出后的回调 URL |

---

### 请求示例

```bash
curl 'https://chat-dev.ainft.com/api/auth/signout' \
  -H 'accept: */*' \
  -H 'content-type: application/x-www-form-urlencoded' \
  -H 'origin: https://chat-dev.ainft.com' \
  -H 'referer: https://chat-dev.ainft.com/chat?session=inbox' \
  -H 'x-auth-return-redirect: 1' \
  -b '__Host-authjs.csrf-token=YOUR_CSRF_TOKEN; __Secure-authjs.session-token=YOUR_SESSION_TOKEN' \
  --data-raw 'csrfToken=YOUR_CSRF_TOKEN&callbackUrl=https%3A%2F%2Fchat-dev.ainft.com%2Fchat%3Fsession%3Dinbox'
```

---

### 响应说明

登出成功后，服务器会：

1. **清除 Session Cookie**: 删除 `__Secure-authjs.session-token`
2. **可选重定向**: 如果提供了 `callbackUrl`，可能会重定向到该地址
3. **返回响应**: 返回登出结果

---

### 注意事项

1. **CSRF 保护**: 需要提供有效的 CSRF 令牌，与 Cookie 中的 `__Host-authjs.csrf-token` 匹配
2. **Cookie 必需**: 必须携带有效的 session token 才能登出
3. **回调 URL**: `callbackUrl` 需要 URL 编码
4. **安全性**: 建议在登出后清除客户端存储的所有认证相关信息

---

### 相关接口

- [Clerk 认证](auth-clerk.md) - 邮箱、手机号、OAuth 登录
- [Google OAuth 登录](auth-google.md) - Google 账号第三方登录
- [TronLink 登录](auth-tronlink.md) - TronLink 钱包登录接口
