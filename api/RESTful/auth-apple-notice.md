# Apple 登录说明



申请 Apple 凭证（需 Apple Developer 账号）

1. [Apple Developer](https://developer.apple.com/account/) → **Certificates, Identifiers & Profiles** → **Identifiers** → 新建 **Services IDs**，得到 **Service ID**（即 `APPLE_ID`，如 `com.example.app`）。
2. 在该 Service ID 中勾选 **Sign in with Apple**，配置 **Domains and Subdomains**（如 `dev.example.com`）和 **Return URLs**（如 `http://localhost:3010/api/auth/callback/apple`）。
3. **Keys** → 新建 Key，勾选 **Sign in with Apple**，下载 `.p8` 私钥（只可下载一次）。记下 **Key ID**。**Team ID** 在登录后页面右上角。
4. 使用 [bal.so/apple-gen-secret](https://bal.so/apple-gen-secret) 或同类工具，用 **Team ID**、**Key ID**、**Service ID** 和 `.p8` 私钥生成 **Client Secret（JWT）**，填入 `.env.local` 的 `APPLE_SECRET`。`APPLE_ID` 填你的 Service ID。


## 当前状态

❌ **ainft 平台目前不支持 Apple 登录（Sign in with Apple）**

根据代码分析，项目中没有集成 Apple 作为认证提供商。

---

## 为什么不支持？

可能的原因：

### 1. Apple 开发者账号要求

- 需要付费的 Apple Developer Program 会员资格（$99/年）
- 需要配置 App ID、Service ID 和私钥
- 配置流程相对复杂

### 2. 平台定位

ainft 平台目前专注于：
- Web3 用户（TronLink 等钱包登录）
- 企业用户（OAuth SSO）
- 通用用户（Clerk、Google、GitHub）

Apple 登录主要用于 iOS 生态，可能不是当前优先级。

### 3. 技术要求

Apple 登录需要：
- HTTPS（必须）
- 经过验证的域名
- 特定的回调 URL 配置
- JWT 私钥管理

---

## 替代方案

如果您需要登录功能，可以使用以下现有方式：

### 推荐方案 1: Clerk 认证

✅ **最接近 Apple 登录体验**

- 支持邮箱魔法链接（无需密码）
- 界面简洁美观
- 支持多因素认证

**文档**: [Clerk 认证接口](./auth-clerk.md)

### 推荐方案 2: Google 登录

✅ **最广泛使用的第三方登录**

- 无需 Apple 设备
- 配置简单
- 用户群体更广

**文档**: [Google OAuth 登录](./auth-google.md)

### 其他方案

- **GitHub 登录**: 适合开发者用户
- **Microsoft 登录**: 适合企业用户
- **TronLink 登录**: 适合 Web3 用户

---

## 如何添加 Apple 登录支持？

如果项目未来需要支持 Apple 登录，以下是实现指南：

### 1. 前置准备

#### 注册 Apple Developer Program

1. 访问 [Apple Developer](https://developer.apple.com/)
2. 注册并支付年费（$99）
3. 创建 App ID 和 Service ID

#### 配置 Sign in with Apple

1. 在 [Apple Developer Console](https://developer.apple.com/account/) 中：
   - 创建新的 **Identifiers**
   - 选择 **App IDs**
   - 启用 **Sign in with Apple**

2. 创建 **Service ID**：
   - 配置 **Return URLs**（回调地址）
   - 配置 **Web Domain**

3. 生成 **Private Key**：
   - 下载 `.p8` 私钥文件
   - 记录 Key ID

### 2. 安装依赖

```bash
pnpm add @auth/core
```

### 3. 创建 Apple Provider

创建文件：`src/libs/next-auth/sso-providers/apple.ts`

```typescript
import Apple from 'next-auth/providers/apple';
import { CommonProviderConfig } from './sso.config';

const provider = {
  id: 'apple',
  provider: Apple({
    ...CommonProviderConfig,
    clientId: process.env.AUTH_APPLE_ID!,
    clientSecret: {
      teamId: process.env.AUTH_APPLE_TEAM_ID!,
      keyId: process.env.AUTH_APPLE_KEY_ID!,
      privateKey: process.env.AUTH_APPLE_PRIVATE_KEY!,
    },
  }),
};

export default provider;
```

### 4. 配置环境变量

在 `src/envs/auth.ts` 中添加：

```typescript
// Apple
AUTH_APPLE_ID: z.string().optional(),
AUTH_APPLE_TEAM_ID: z.string().optional(),
AUTH_APPLE_KEY_ID: z.string().optional(),
AUTH_APPLE_PRIVATE_KEY: z.string().optional(),
```

在 `.env` 文件中设置：

```bash
# Apple Sign In
AUTH_APPLE_ID=com.yourcompany.services
AUTH_APPLE_TEAM_ID=TEAM123456
AUTH_APPLE_KEY_ID=KEY123456
AUTH_APPLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg...
-----END PRIVATE KEY-----"

# 添加到提供商列表
NEXT_AUTH_SSO_PROVIDERS=apple,google,github
```

### 5. 注册 Provider

在 `src/libs/next-auth/sso-providers/index.ts` 中：

```typescript
import Apple from './apple';

export const ssoProviders = [
  // ... 其他提供商
  Apple,
];
```

### 6. 前端实现

```tsx
'use client';

import { signIn } from 'next-auth/react';

export function AppleLoginButton() {
  return (
    <button
      onClick={() => signIn('apple', { callbackUrl: '/chat' })}
      className="w-full flex items-center justify-center gap-3 px-4 py-3 bg-black text-white rounded-lg hover:bg-gray-900"
    >
      <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
        <path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09l.01-.01zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z"/>
      </svg>
      使用 Apple 登录
    </button>
  );
}
```

### 7. 配置回调 URL

在 Apple Developer Console 中添加：

```
生产环境：
https://your-domain.com/api/auth/callback/apple

开发环境：
https://localhost:3000/api/auth/callback/apple
```

**注意**: Apple 要求回调 URL 必须使用 HTTPS（开发环境也需要）。

### 8. 本地开发 HTTPS

开发环境需要配置 HTTPS：

```bash
# 使用 mkcert 创建本地证书
brew install mkcert
mkcert -install
mkcert localhost

# 启动开发服务器
HTTPS=true npm run dev
```

或使用 ngrok：

```bash
ngrok http 3000
# 使用 ngrok 提供的 HTTPS URL
```

---

## Apple 登录特性

如果实现 Apple 登录，将获得以下特性：

### ✅ 优势

1. **隐私保护**
   - 用户可以隐藏真实邮箱
   - Apple 提供中转邮箱（如 `xyz@privaterelay.appleid.com`）

2. **一键登录**
   - iOS/macOS 设备上极其便捷
   - 支持 Face ID / Touch ID

3. **可信度高**
   - Apple 验证用户身份
   - 减少虚假账号

4. **App Store 要求**
   - 如果提供其他社交登录，Apple 要求必须提供 Apple 登录

### ❌ 限制

1. **仅支持 Apple 生态**
   - Android/Windows 用户体验一般
   - 需要 Apple ID

2. **邮箱中转问题**
   - 用户可能隐藏真实邮箱
   - 无法直接联系用户

3. **配置复杂**
   - 需要 JWT 私钥
   - 回调配置严格
   - 必须使用 HTTPS

4. **测试困难**
   - 本地开发需要 HTTPS
   - 需要 Apple ID 测试账号

---

## 使用场景建议

### 推荐使用 Apple 登录的场景

- ✅ 主要面向 iOS 用户的应用
- ✅ 已在 App Store 上架的应用
- ✅ 重视用户隐私的应用
- ✅ 提供了其他社交登录的应用（App Store 要求）

### 不推荐使用的场景

- ❌ 主要面向 Web/Android 用户
- ❌ 开发资源有限
- ❌ 没有 Apple Developer 账号
- ❌ 已有足够的登录方式

---

## 成本分析

### 直接成本

- Apple Developer Program: **$99/年**

### 开发成本

- 配置时间: **2-4 小时**
- 开发时间: **4-8 小时**
- 测试时间: **2-4 小时**
- 总计: **1-2 天**

### 维护成本

- 私钥管理和轮换
- 回调 URL 更新
- 用户反馈处理

---

## 推荐方案

根据 ainft 平台的特点，建议：

### 当前策略 ✅

保持现有认证方式：
1. **Clerk** - 通用用户（含邮箱登录）
2. **Google** - Web 用户
3. **TronLink** - Web3 用户
4. **GitHub** - 开发者用户

**理由**:
- 覆盖 90%+ 的用户群体
- 配置简单，维护成本低
- 不依赖特定生态系统

### 未来扩展 🔮

如果满足以下条件，可以考虑添加 Apple 登录：

1. ✅ 推出 iOS 原生应用
2. ✅ iOS 用户占比 > 30%
3. ✅ 用户明确反馈需求
4. ✅ 已有 Apple Developer 账号

---

## 常见问题

### Q: 为什么 Clerk 不能代替 Apple 登录？

A: Clerk 支持邮箱登录，但不能满足 App Store 的要求。如果您的应用提供了 Google/Facebook 登录，App Store 要求必须同时提供 Apple 登录。

### Q: 可以只在 iOS 上提供 Apple 登录吗？

A: 可以。NextAuth 支持根据平台动态显示登录选项：

```typescript
const isIOS = /iPhone|iPad|iPod/.test(navigator.userAgent);

{isIOS && <AppleLoginButton />}
```

### Q: Apple 隐藏邮箱会影响用户管理吗？

A: 会有一定影响。建议：
- 使用 Apple 提供的用户唯一标识符
- 在用户首次登录时要求补充信息
- 提供用户自己绑定真实邮箱的选项

---

## 相关文档

- [认证方式概览](./auth-overview.md) - 所有认证方式对比
- [Clerk 认证](./auth-clerk.md) - 推荐的邮箱登录方式
- [Google OAuth](./auth-google.md) - 推荐的第三方登录
- [Apple Developer 文档](https://developer.apple.com/sign-in-with-apple/)

---

最后更新: 2026-02-14
