# 认证方式概览

ainft 平台支持多种认证方式，满足不同用户群体和使用场景的需求。

## 支持的认证方式

### 1. 🔐 Clerk 认证（推荐）

**适用场景**: Web2 用户、需要传统登录方式

**支持的登录方式**:
- ✅ 邮箱 + 密码
- ✅ 邮箱魔法链接（无需密码）
- ✅ 手机号 + 验证码
- ✅ OAuth 第三方登录（Google, GitHub 等）
- ✅ 多因素认证（MFA）

**优势**:
- 🎯 用户体验好，无需安装钱包
- 🔒 支持多因素认证，安全性高
- 📧 支持邮件通知和用户管理
- 🆓 有免费额度（10,000 月活跃用户）

**文档**: [Clerk 认证接口](./auth-clerk.md)

---

### 2. 🦊 TronLink 钱包登录

**适用场景**: Web3 用户、去中心化应用

**特点**:
- ✅ 完全去中心化
- ✅ 无需注册，直接使用钱包地址
- ✅ 支持签名验证
- ✅ 与 TRON 区块链深度集成

**优势**:
- 🌐 去中心化身份
- 💰 可以直接使用积分系统（TRX）
- 🔓 无需记住密码
- 🆓 完全免费

**文档**: [TronLink 登录接口](./auth-tronlink.md)

---

### 3. 🌍 其他 Web3 钱包

除了 TronLink，还支持以下 Web3 钱包登录：

| 钱包 | 区块链 | 说明 |
|------|--------|------|
| MetaMask | Ethereum | 最流行的以太坊钱包 |
| OKX | 多链 | 支持多条区块链 |
| TokenPocket | 多链 | 多链钱包 |
| Binance | BSC | 币安智能链 |
| Bybit | 多链 | 交易所钱包 |

**配置方式**: 与 TronLink 类似，通过 NextAuth 配置

---

### 4. 🔑 OAuth 第三方登录

**支持的提供商**:

#### 常用社交登录
- Google
- GitHub
- Microsoft (Azure AD)

#### 企业 SSO
- Auth0
- Okta
- Keycloak
- Azure AD
- Microsoft Entra ID

#### 开源认证服务
- Authentik
- Authelia
- Zitadel
- Logto
- Casdoor

#### 其他
- Cloudflare Zero Trust
- AWS Cognito
- WeChat (微信)
- Feishu (飞书)

**配置方式**: 通过环境变量配置，详见下文

---

## 认证方式对比

| 功能特性 | Clerk | TronLink | OAuth SSO |
|---------|-------|----------|-----------|
| **邮箱登录** | ✅ | ❌ | ✅ (部分) |
| **密码登录** | ✅ | ❌ | ✅ (部分) |
| **魔法链接** | ✅ | ❌ | ❌ |
| **手机号登录** | ✅ | ❌ | ❌ |
| **Web3 钱包** | 可选 | ✅ | ❌ |
| **去中心化** | ❌ | ✅ | ❌ |
| **多因素认证** | ✅ | ❌ | ✅ (部分) |
| **用户管理** | ✅ | ❌ | ✅ |
| **免费使用** | 10k MAU | 无限 | 取决于提供商 |
| **开发难度** | 简单 | 中等 | 简单 |
| **用户体验** | 优秀 | 中等 | 优秀 |

---

## 如何选择认证方式

### 场景 1: 面向普通用户的产品

**推荐**: Clerk 认证

```
✅ 用户无需了解 Web3 概念
✅ 支持多种登录方式
✅ 用户体验好
✅ 易于集成和维护
```

**示例**: SaaS 应用、内容平台、社区网站

---

### 场景 2: Web3 原生应用

**推荐**: TronLink（或其他 Web3 钱包）

```
✅ 用户已有 Web3 钱包
✅ 需要区块链交互
✅ 去中心化身份重要
✅ 与代币/NFT 集成
```

**示例**: DeFi 应用、NFT 市场、DAO 平台

---

### 场景 3: 企业内部应用

**推荐**: OAuth SSO（如 Azure AD, Okta）

```
✅ 与企业现有账号系统集成
✅ 统一身份管理
✅ 符合企业安全政策
✅ 支持单点登录（SSO）
```

**示例**: 企业内部工具、B2B SaaS

---

### 场景 4: 混合用户群体

**推荐**: Clerk + TronLink（双认证系统）

```
✅ 同时支持 Web2 和 Web3 用户
✅ 用户可选择偏好的登录方式
✅ 最大化用户覆盖面
```

**实现方式**:
```typescript
// 提供多种登录选项
<div>
  <ClerkSignIn />  {/* Web2 用户 */}
  <TronLinkLogin /> {/* Web3 用户 */}
</div>
```

---

## 配置指南

### 启用 Clerk 认证

```bash
# .env
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_live_xxxxxxxxxxx
CLERK_SECRET_KEY=sk_live_xxxxxxxxxxxxxxxxxxxxxx
CLERK_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxxxxxxxxxxx
```

自动启用，无需其他配置。

---

### 启用 TronLink 认证

```bash
# .env
NEXT_PUBLIC_ENABLE_NEXT_AUTH=1
NEXT_AUTH_SECRET=your-secret-key
NEXT_AUTH_SSO_PROVIDERS=tronlink
```

---

### 启用多个认证方式

```bash
# .env
# 同时启用 Clerk 和 TronLink
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_live_xxxxxxxxxxx
CLERK_SECRET_KEY=sk_live_xxxxxxxxxxxxxxxxxxxxxx

NEXT_PUBLIC_ENABLE_NEXT_AUTH=1
NEXT_AUTH_SECRET=your-secret-key
NEXT_AUTH_SSO_PROVIDERS=tronlink,github,google
```

---

### 配置 OAuth 提供商

以 Google 为例：

```bash
# .env
NEXT_PUBLIC_ENABLE_NEXT_AUTH=1
NEXT_AUTH_SECRET=your-secret-key
NEXT_AUTH_SSO_PROVIDERS=google

# Google OAuth
AUTH_GOOGLE_ID=your-google-client-id
AUTH_GOOGLE_SECRET=your-google-client-secret
```

其他提供商类似，参考环境变量命名规则：
- `AUTH_{PROVIDER}_ID`
- `AUTH_{PROVIDER}_SECRET`
- `AUTH_{PROVIDER}_ISSUER`（OIDC 提供商需要）

---

## 前端实现示例

### 统一登录页面

```tsx
'use client';

import { SignIn } from '@clerk/nextjs';
import { TronLinkLoginButton } from '@/components/TronLinkLogin';
import { useState } from 'react';

export default function UnifiedLoginPage() {
  const [loginMethod, setLoginMethod] = useState<'clerk' | 'web3'>('clerk');

  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="w-full max-w-md">
        {/* 选择登录方式 */}
        <div className="flex gap-2 mb-6">
          <button
            onClick={() => setLoginMethod('clerk')}
            className={`flex-1 py-2 px-4 rounded ${
              loginMethod === 'clerk' 
                ? 'bg-blue-600 text-white' 
                : 'bg-gray-200'
            }`}
          >
            邮箱/手机登录
          </button>
          <button
            onClick={() => setLoginMethod('web3')}
            className={`flex-1 py-2 px-4 rounded ${
              loginMethod === 'web3' 
                ? 'bg-blue-600 text-white' 
                : 'bg-gray-200'
            }`}
          >
            钱包登录
          </button>
        </div>

        {/* 登录表单 */}
        {loginMethod === 'clerk' ? (
          <SignIn 
            routing="path"
            path="/sign-in"
            redirectUrl="/chat"
          />
        ) : (
          <div className="space-y-4">
            <TronLinkLoginButton />
            <button className="w-full py-3 bg-gray-800 text-white rounded">
              MetaMask 登录
            </button>
            <button className="w-full py-3 bg-gray-800 text-white rounded">
              OKX 登录
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
```

---

## 安全建议

### 1. 始终使用 HTTPS

所有认证流程必须在 HTTPS 下进行。

```nginx
# Nginx 配置
server {
    listen 443 ssl http2;
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    # 强制 HTTPS
    add_header Strict-Transport-Security "max-age=31536000" always;
}
```

### 2. 保护敏感环境变量

```bash
# 不要提交到 Git
echo ".env" >> .gitignore
echo ".env.local" >> .gitignore

# 使用密钥管理服务
# - Vercel: 使用 Environment Variables
# - Docker: 使用 secrets
# - K8s: 使用 ConfigMap/Secrets
```

### 3. 实施速率限制

```typescript
// middleware.ts
import { rateLimit } from '@/lib/rate-limit';

export async function middleware(request: Request) {
  // 限制登录尝试
  if (request.url.includes('/api/auth/')) {
    const { success } = await rateLimit(request);
    if (!success) {
      return new Response('Too many requests', { status: 429 });
    }
  }
}
```

### 4. 启用 CSRF 保护

所有认证端点都应启用 CSRF 保护（已内置）。

### 5. 日志记录

记录所有认证事件用于安全审计：

```typescript
// 登录成功
logger.info('User logged in', {
  userId,
  method: 'tronlink',
  ip: request.ip,
  timestamp: new Date(),
});

// 登录失败
logger.warn('Login failed', {
  identifier: email,
  reason: 'invalid_password',
  ip: request.ip,
});
```

---

## 常见问题

### Q: 可以同时使用多种认证方式吗？

A: 可以！Clerk 和 NextAuth（Web3 钱包、OAuth）可以同时启用。用户可以选择任意方式登录。

### Q: 不同认证方式的用户 ID 如何统一？

A: 每种认证方式都会在数据库中创建独立的用户记录。如果需要关联，可以通过邮箱或其他唯一标识符。

### Q: Clerk 和 NextAuth 哪个更好？

A: 取决于需求：
- **Clerk**: 更适合需要完整用户管理的应用
- **NextAuth**: 更灵活，适合 Web3 应用和企业 SSO

### Q: 如何迁移用户数据？

A: 可以通过导入接口批量导入用户：

```typescript
// 导入到 Clerk
await clerkClient.users.createUser({
  emailAddress: ['user@example.com'],
  password: 'hashed-password',
});

// 导入到数据库（NextAuth）
await db.insert(users).values({
  id: userId,
  email: 'user@example.com',
  // ...
});
```

---

## 相关文档

- [Clerk 认证接口](./auth-clerk.md) - 完整的 Clerk 集成指南
- [TronLink 登录接口](./auth-tronlink.md) - TronLink 钱包登录
- [用户管理接口](../tRPC/lambda/user.md) - 用户信息和设置

---

最后更新: 2026-02-14
