# Clerk 认证接口（包含邮箱登录）

Clerk 是一个现代化的认证服务，支持邮箱、手机号、OAuth 等多种登录方式。

## 认证方式支持

Clerk 提供以下认证方式：

- ✅ **邮箱 + 密码**
- ✅ **邮箱魔法链接**（无需密码，通过邮件链接登录）
- ✅ **手机号 + 验证码**
- ✅ **OAuth 第三方登录**（Google, GitHub, Microsoft 等）
- ✅ **多因素认证（MFA）**
- ✅ **Web3 钱包**（可选）

## 配置要求

### 环境变量

```bash
# Clerk 公钥（前端使用）
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_live_xxxxxxxxxxx

# Clerk 密钥（后端使用）
CLERK_SECRET_KEY=sk_live_xxxxxxxxxxxxxxxxxxxxxx

# Clerk Webhook 密钥（用于数据库同步）
CLERK_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxxxxxxxxxxx

# 跨域认证（可选）
NEXT_PUBLIC_CLERK_AUTH_ALLOW_ORIGINS='https://example.com,https://another.com'
```

### 启用 Clerk

只需要设置 `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` 环境变量，Clerk 认证会自动启用。

---

## Clerk 认证流程

```
1. 用户访问登录页面
   ↓
2. Clerk 组件渲染（邮箱/手机/OAuth）
   ↓
3. 用户输入邮箱或选择登录方式
   ↓
4. Clerk 处理认证（发送验证码/魔法链接/OAuth）
   ↓
5. 用户完成验证
   ↓
6. Clerk 创建会话
   ↓
7. 后端通过 Webhook 同步用户数据
   ↓
8. 用户登录成功
```

---

## 前端集成

### 1. 安装 Clerk SDK

```bash
pnpm add @clerk/nextjs
```

### 2. 配置 Clerk Provider

```tsx
// app/layout.tsx
import { ClerkProvider } from '@clerk/nextjs';

export default function RootLayout({ children }) {
  return (
    <ClerkProvider>
      <html lang="zh-CN">
        <body>{children}</body>
      </html>
    </ClerkProvider>
  );
}
```

### 3. 使用 Clerk 登录组件

#### 邮箱 + 密码登录

```tsx
import { SignIn } from '@clerk/nextjs';

export default function SignInPage() {
  return (
    <div className="flex justify-center items-center min-h-screen">
      <SignIn 
        appearance={{
          elements: {
            rootBox: "mx-auto",
            card: "shadow-lg"
          }
        }}
        routing="path"
        path="/sign-in"
        signUpUrl="/sign-up"
        redirectUrl="/chat"
      />
    </div>
  );
}
```

#### 邮箱魔法链接登录

```tsx
import { SignIn } from '@clerk/nextjs';

export default function MagicLinkSignIn() {
  return (
    <SignIn
      appearance={{
        variables: {
          colorPrimary: '#0066FF'
        }
      }}
      // 强制使用邮箱链接模式
      initialValues={{
        emailAddress: '',
      }}
      // 自定义配置
      signUpUrl="/sign-up"
      redirectUrl="/chat"
    />
  );
}
```

#### 注册页面

```tsx
import { SignUp } from '@clerk/nextjs';

export default function SignUpPage() {
  return (
    <div className="flex justify-center items-center min-h-screen">
      <SignUp
        appearance={{
          elements: {
            formButtonPrimary: 'bg-blue-600 hover:bg-blue-700',
          }
        }}
        routing="path"
        path="/sign-up"
        signInUrl="/sign-in"
        redirectUrl="/chat"
      />
    </div>
  );
}
```

### 4. 自定义邮箱登录表单

如果需要完全自定义 UI：

```tsx
'use client';

import { useSignIn } from '@clerk/nextjs';
import { useState } from 'react';
import { useRouter } from 'next/navigation';

export function CustomEmailSignIn() {
  const { isLoaded, signIn, setActive } = useSignIn();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!isLoaded) return;

    try {
      // 使用邮箱 + 密码登录
      const result = await signIn.create({
        identifier: email,
        password,
      });

      if (result.status === 'complete') {
        // 设置活动会话
        await setActive({ session: result.createdSessionId });
        // 跳转到聊天页面
        router.push('/chat');
      } else {
        console.log('需要额外验证:', result);
      }
    } catch (err: any) {
      setError(err.errors?.[0]?.message || '登录失败');
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label htmlFor="email" className="block text-sm font-medium">
          邮箱地址
        </label>
        <input
          id="email"
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          className="mt-1 block w-full px-3 py-2 border rounded-md"
          required
        />
      </div>
      
      <div>
        <label htmlFor="password" className="block text-sm font-medium">
          密码
        </label>
        <input
          id="password"
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          className="mt-1 block w-full px-3 py-2 border rounded-md"
          required
        />
      </div>

      {error && (
        <div className="text-red-600 text-sm">{error}</div>
      )}

      <button
        type="submit"
        className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700"
      >
        登录
      </button>
    </form>
  );
}
```

### 5. 邮箱魔法链接登录（自定义）

```tsx
'use client';

import { useSignIn } from '@clerk/nextjs';
import { useState } from 'react';

export function MagicLinkSignIn() {
  const { isLoaded, signIn } = useSignIn();
  const [email, setEmail] = useState('');
  const [sentEmail, setSentEmail] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!isLoaded) return;

    try {
      // 发送魔法链接到邮箱
      await signIn.create({
        identifier: email,
        strategy: 'email_link',
        redirectUrl: '/verify-email',
      });

      setSentEmail(true);
    } catch (err: any) {
      setError(err.errors?.[0]?.message || '发送失败');
    }
  };

  if (sentEmail) {
    return (
      <div className="text-center">
        <h2 className="text-2xl font-bold mb-4">查看您的邮箱</h2>
        <p className="text-gray-600">
          我们已将登录链接发送到 <strong>{email}</strong>
        </p>
        <p className="text-sm text-gray-500 mt-2">
          点击邮件中的链接即可登录
        </p>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label htmlFor="email" className="block text-sm font-medium">
          邮箱地址
        </label>
        <input
          id="email"
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="your@email.com"
          className="mt-1 block w-full px-3 py-2 border rounded-md"
          required
        />
      </div>

      {error && (
        <div className="text-red-600 text-sm">{error}</div>
      )}

      <button
        type="submit"
        className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700"
      >
        发送登录链接
      </button>
    </form>
  );
}
```

### 6. 邮箱注册（自定义）

```tsx
'use client';

import { useSignUp } from '@clerk/nextjs';
import { useState } from 'react';
import { useRouter } from 'next/navigation';

export function EmailSignUp() {
  const { isLoaded, signUp, setActive } = useSignUp();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [verifying, setVerifying] = useState(false);
  const [code, setCode] = useState('');
  const [error, setError] = useState('');
  const router = useRouter();

  // 第一步：发送验证码
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!isLoaded) return;

    try {
      await signUp.create({
        emailAddress: email,
        password,
      });

      // 发送验证码到邮箱
      await signUp.prepareEmailAddressVerification({
        strategy: 'email_code',
      });

      setVerifying(true);
    } catch (err: any) {
      setError(err.errors?.[0]?.message || '注册失败');
    }
  };

  // 第二步：验证邮箱
  const handleVerify = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!isLoaded) return;

    try {
      const result = await signUp.attemptEmailAddressVerification({
        code,
      });

      if (result.status === 'complete') {
        await setActive({ session: result.createdSessionId });
        router.push('/chat');
      }
    } catch (err: any) {
      setError(err.errors?.[0]?.message || '验证失败');
    }
  };

  if (verifying) {
    return (
      <form onSubmit={handleVerify} className="space-y-4">
        <div>
          <label className="block text-sm font-medium">
            请输入发送到 {email} 的验证码
          </label>
          <input
            type="text"
            value={code}
            onChange={(e) => setCode(e.target.value)}
            placeholder="验证码"
            className="mt-1 block w-full px-3 py-2 border rounded-md"
            required
          />
        </div>

        {error && <div className="text-red-600 text-sm">{error}</div>}

        <button
          type="submit"
          className="w-full bg-blue-600 text-white py-2 px-4 rounded-md"
        >
          验证并注册
        </button>
      </form>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div>
        <label htmlFor="email" className="block text-sm font-medium">
          邮箱地址
        </label>
        <input
          id="email"
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          className="mt-1 block w-full px-3 py-2 border rounded-md"
          required
        />
      </div>
      
      <div>
        <label htmlFor="password" className="block text-sm font-medium">
          密码（至少 8 位）
        </label>
        <input
          id="password"
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          className="mt-1 block w-full px-3 py-2 border rounded-md"
          minLength={8}
          required
        />
      </div>

      {error && <div className="text-red-600 text-sm">{error}</div>}

      <button
        type="submit"
        className="w-full bg-blue-600 text-white py-2 px-4 rounded-md"
      >
        注册
      </button>
    </form>
  );
}
```

---

## 获取用户信息

### 使用 Hook

```tsx
'use client';

import { useUser } from '@clerk/nextjs';

export function UserProfile() {
  const { isLoaded, isSignedIn, user } = useUser();

  if (!isLoaded) {
    return <div>加载中...</div>;
  }

  if (!isSignedIn) {
    return <div>未登录</div>;
  }

  return (
    <div>
      <h2>欢迎, {user.firstName || user.emailAddresses[0].emailAddress}!</h2>
      <p>用户 ID: {user.id}</p>
      <p>邮箱: {user.primaryEmailAddress?.emailAddress}</p>
    </div>
  );
}
```

### 服务端获取用户

```tsx
import { currentUser } from '@clerk/nextjs/server';

export default async function ServerComponent() {
  const user = await currentUser();

  if (!user) {
    return <div>未登录</div>;
  }

  return (
    <div>
      <p>用户 ID: {user.id}</p>
      <p>邮箱: {user.emailAddresses[0].emailAddress}</p>
    </div>
  );
}
```

---

## 退出登录

```tsx
'use client';

import { useClerk } from '@clerk/nextjs';

export function SignOutButton() {
  const { signOut } = useClerk();

  return (
    <button
      onClick={() => signOut()}
      className="px-4 py-2 bg-red-600 text-white rounded-md"
    >
      退出登录
    </button>
  );
}
```

---

## 后端 Webhook 同步

当用户通过 Clerk 登录时，需要通过 Webhook 同步用户数据到应用数据库。

### Webhook 端点

**路径**: `/api/auth/adapter`（自动处理）

**事件类型**:
- `user.created` - 用户创建
- `user.updated` - 用户更新
- `user.deleted` - 用户删除

### Webhook 配置

1. 在 Clerk Dashboard 设置 Webhook URL：
   ```
   https://your-domain.com/api/auth/adapter
   ```

2. 选择要监听的事件：
   - user.created
   - user.updated
   - user.deleted

3. 复制 Signing Secret 并设置环境变量：
   ```bash
   CLERK_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxxxxxxxxxxx
   ```

---

## Clerk vs TronLink

| 功能 | Clerk | TronLink |
|------|-------|----------|
| 邮箱登录 | ✅ | ❌ |
| 密码登录 | ✅ | ❌ |
| 魔法链接 | ✅ | ❌ |
| Web3 钱包 | 可选 | ✅ |
| 去中心化 | ❌ | ✅ |
| 多因素认证 | ✅ | ❌ |
| 用户管理 | ✅ | ❌ |
| 免费额度 | 10,000 MAU | 完全免费 |

---

## 邮箱登录配置

### 1. 在 Clerk Dashboard 中启用邮箱登录

1. 进入 Clerk Dashboard
2. 导航到 **User & Authentication** → **Email, Phone, Username**
3. 启用 **Email address**
4. 选择验证方式：
   - ✅ **Email verification code** (验证码)
   - ✅ **Email verification link** (魔法链接)

### 2. 配置邮件模板

可以自定义邮件模板：
1. 导航到 **Customization** → **Emails**
2. 编辑验证邮件模板
3. 自定义品牌、Logo、文案

### 3. 配置密码策略

1. 导航到 **User & Authentication** → **Restrictions**
2. 设置密码要求：
   - 最小长度（推荐 8 位）
   - 复杂度要求
   - 密码历史

---

## 安全最佳实践

### 1. 启用多因素认证（MFA）

```tsx
import { useUser } from '@clerk/nextjs';

export function EnableMFA() {
  const { user } = useUser();

  const handleEnableMFA = async () => {
    try {
      await user?.createTOTP();
      // 引导用户完成 MFA 设置
    } catch (error) {
      console.error('MFA 设置失败:', error);
    }
  };

  return (
    <button onClick={handleEnableMFA}>
      启用双因素认证
    </button>
  );
}
```

### 2. 会话管理

```tsx
import { useSession } from '@clerk/nextjs';

export function SessionInfo() {
  const { session, isLoaded } = useSession();

  if (!isLoaded) return null;

  return (
    <div>
      <p>会话 ID: {session?.id}</p>
      <p>最后活跃: {session?.lastActiveAt.toLocaleString()}</p>
      <p>过期时间: {session?.expireAt.toLocaleString()}</p>
    </div>
  );
}
```

### 3. 强制重新认证

```tsx
import { useAuth } from '@clerk/nextjs';

export function SensitiveAction() {
  const { sessionId, getToken } = useAuth();

  const handleSensitiveAction = async () => {
    // 获取新 Token（可能触发重新认证）
    const token = await getToken({ 
      template: 'default',
      skipCache: true // 跳过缓存
    });

    // 执行敏感操作...
  };

  return (
    <button onClick={handleSensitiveAction}>
      执行敏感操作
    </button>
  );
}
```

---

## 错误处理

```tsx
import { isClerkAPIResponseError } from '@clerk/nextjs/errors';

try {
  await signIn.create({ identifier: email, password });
} catch (error) {
  if (isClerkAPIResponseError(error)) {
    // Clerk API 错误
    console.error('Clerk 错误:', error.errors);
    
    error.errors.forEach((err) => {
      if (err.code === 'form_password_incorrect') {
        alert('密码错误');
      } else if (err.code === 'form_identifier_not_found') {
        alert('用户不存在');
      }
    });
  } else {
    // 其他错误
    console.error('未知错误:', error);
  }
}
```

---

## TypeScript 类型

```typescript
import type { User, Session } from '@clerk/nextjs/server';

interface ClerkUser extends User {
  id: string;
  emailAddresses: Array<{
    emailAddress: string;
    id: string;
  }>;
  primaryEmailAddress: {
    emailAddress: string;
  } | null;
  firstName: string | null;
  lastName: string | null;
  imageUrl: string;
}
```

---

## 相关资源

- [Clerk 官方文档](https://clerk.com/docs)
- [Clerk Next.js 快速开始](https://clerk.com/docs/quickstarts/nextjs)
- [Clerk Dashboard](https://dashboard.clerk.com)

---

最后更新: 2026-02-14
