# Google OAuth 登录接口

使用 Google 账号进行第三方登录，支持所有 Google 账号用户。

## 特点

- ✅ **无需注册**：使用现有 Google 账号直接登录
- ✅ **安全可靠**：基于 OAuth 2.0 标准协议
- ✅ **快速便捷**：一键登录，无需填写表单
- ✅ **自动同步**：自动获取用户头像、昵称、邮箱
- ✅ **跨平台**：支持 Web、移动端

---

## 配置要求

### 1. 创建 Google OAuth 应用

访问 [Google Cloud Console](https://console.cloud.google.com/)：

1. 创建或选择项目
2. 启用 **Google+ API**
3. 转到 **凭据** → **创建凭据** → **OAuth 2.0 客户端 ID**
4. 配置 OAuth 同意屏幕
5. 创建 Web 应用凭据

### 2. 配置回调 URL

在 Google Cloud Console 中添加授权重定向 URI：

```
生产环境：
https://your-domain.com/api/auth/callback/google

开发环境：
http://localhost:3000/api/auth/callback/google
```

### 3. 环境变量配置

```bash
# .env

# 启用 NextAuth
NEXT_PUBLIC_ENABLE_NEXT_AUTH=1
NEXT_AUTH_SECRET=your-secret-key-here

# 配置提供商（包含 google）
NEXT_AUTH_SSO_PROVIDERS=google

# Google OAuth 凭据
AUTH_GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com
AUTH_GOOGLE_CLIENT_SECRET=your-google-client-secret
```

**获取凭据**：
- `CLIENT_ID`: 从 Google Cloud Console 的凭据页面获取
- `CLIENT_SECRET`: 创建凭据时生成

---

## OAuth 登录流程

```
1. 用户点击"使用 Google 登录"
   ↓
2. 跳转到 Google 授权页面
   ↓
3. 用户选择 Google 账号并授权
   ↓
4. Google 回调到应用 (/api/auth/callback/google)
   ↓
5. 后端验证授权码并获取用户信息
   ↓
6. 创建或更新用户记录
   ↓
7. 创建会话并跳转到应用
```

---

## 前端实现

### 1. 使用 NextAuth 登录按钮

```tsx
'use client';

import { signIn } from 'next-auth/react';

export function GoogleLoginButton() {
  const handleGoogleLogin = async () => {
    try {
      await signIn('google', {
        callbackUrl: '/chat',  // 登录成功后跳转
        redirect: true,
      });
    } catch (error) {
      console.error('Google 登录失败:', error);
    }
  };

  return (
    <button
      onClick={handleGoogleLogin}
      className="flex items-center gap-2 px-4 py-2 bg-white border border-gray-300 rounded-lg hover:bg-gray-50"
    >
      <svg width="20" height="20" viewBox="0 0 20 20">
        {/* Google Logo SVG */}
        <path fill="#4285F4" d="M19.6 10.23c0-.82-.1-1.42-.25-2.05H10v3.72h5.5c-.15.96-.74 2.31-2.04 3.22v2.45h3.16c1.89-1.73 2.98-4.3 2.98-7.34z"/>
        <path fill="#34A853" d="M13.46 15.13c-.83.59-1.96 1-3.46 1-2.64 0-4.88-1.74-5.68-4.15H1.07v2.52C2.72 17.75 6.09 20 10 20c2.7 0 4.96-.89 6.62-2.42l-3.16-2.45z"/>
        <path fill="#FBBC05" d="M3.99 10c0-.69.12-1.35.32-1.97V5.51H1.07A9.973 9.973 0 000 10c0 1.61.39 3.14 1.07 4.49l3.24-2.52c-.2-.62-.32-1.28-.32-1.97z"/>
        <path fill="#EA4335" d="M10 3.88c1.88 0 3.13.81 3.85 1.48l2.84-2.76C14.96.99 12.7 0 10 0 6.09 0 2.72 2.25 1.07 5.51l3.24 2.52C5.12 5.62 7.36 3.88 10 3.88z"/>
      </svg>
      使用 Google 登录
    </button>
  );
}
```

### 2. 自定义样式登录按钮

```tsx
'use client';

import { signIn } from 'next-auth/react';
import Image from 'next/image';

export function CustomGoogleButton() {
  return (
    <button
      onClick={() => signIn('google', { callbackUrl: '/chat' })}
      className="w-full flex items-center justify-center gap-3 px-6 py-3 bg-white text-gray-700 font-medium rounded-lg border-2 border-gray-200 hover:border-blue-500 hover:shadow-md transition-all"
    >
      <Image 
        src="/images/google-icon.svg" 
        alt="Google" 
        width={24} 
        height={24} 
      />
      <span>使用 Google 账号登录</span>
    </button>
  );
}
```

### 3. 多种登录方式组合

```tsx
'use client';

import { signIn } from 'next-auth/react';

export function SocialLoginButtons() {
  const providers = [
    { 
      id: 'google', 
      name: 'Google',
      icon: '🔍',
      color: 'bg-white hover:bg-gray-50 text-gray-700 border-gray-300'
    },
    { 
      id: 'github', 
      name: 'GitHub',
      icon: '🐙',
      color: 'bg-gray-900 hover:bg-gray-800 text-white'
    },
  ];

  return (
    <div className="space-y-3">
      {providers.map((provider) => (
        <button
          key={provider.id}
          onClick={() => signIn(provider.id, { callbackUrl: '/chat' })}
          className={`w-full flex items-center justify-center gap-3 px-4 py-3 rounded-lg border transition ${provider.color}`}
        >
          <span className="text-2xl">{provider.icon}</span>
          <span>使用 {provider.name} 登录</span>
        </button>
      ))}
    </div>
  );
}
```

### 4. 完整登录页面示例

```tsx
'use client';

import { signIn, useSession } from 'next-auth/react';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';

export default function LoginPage() {
  const { data: session, status } = useSession();
  const router = useRouter();

  useEffect(() => {
    if (status === 'authenticated') {
      router.push('/chat');
    }
  }, [status, router]);

  if (status === 'loading') {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-50">
      <div className="w-full max-w-md p-8 bg-white rounded-lg shadow-lg">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            欢迎回来
          </h1>
          <p className="text-gray-600">
            选择您喜欢的方式登录
          </p>
        </div>

        {/* Google 登录按钮 */}
        <button
          onClick={() => signIn('google', { callbackUrl: '/chat' })}
          className="w-full flex items-center justify-center gap-3 px-4 py-3 mb-4 bg-white text-gray-700 font-medium rounded-lg border-2 border-gray-300 hover:border-blue-500 hover:shadow-md transition"
        >
          <svg width="20" height="20" viewBox="0 0 20 20">
            <path fill="#4285F4" d="M19.6 10.23c0-.82-.1-1.42-.25-2.05H10v3.72h5.5c-.15.96-.74 2.31-2.04 3.22v2.45h3.16c1.89-1.73 2.98-4.3 2.98-7.34z"/>
            <path fill="#34A853" d="M13.46 15.13c-.83.59-1.96 1-3.46 1-2.64 0-4.88-1.74-5.68-4.15H1.07v2.52C2.72 17.75 6.09 20 10 20c2.7 0 4.96-.89 6.62-2.42l-3.16-2.45z"/>
            <path fill="#FBBC05" d="M3.99 10c0-.69.12-1.35.32-1.97V5.51H1.07A9.973 9.973 0 000 10c0 1.61.39 3.14 1.07 4.49l3.24-2.52c-.2-.62-.32-1.28-.32-1.97z"/>
            <path fill="#EA4335" d="M10 3.88c1.88 0 3.13.81 3.85 1.48l2.84-2.76C14.96.99 12.7 0 10 0 6.09 0 2.72 2.25 1.07 5.51l3.24 2.52C5.12 5.62 7.36 3.88 10 3.88z"/>
          </svg>
          使用 Google 账号登录
        </button>

        <div className="relative my-6">
          <div className="absolute inset-0 flex items-center">
            <div className="w-full border-t border-gray-300"></div>
          </div>
          <div className="relative flex justify-center text-sm">
            <span className="px-2 bg-white text-gray-500">或</span>
          </div>
        </div>

        {/* 其他登录方式 */}
        <div className="text-center text-sm text-gray-600">
          <a href="/login/email" className="text-blue-600 hover:underline">
            使用邮箱登录
          </a>
        </div>
      </div>
    </div>
  );
}
```

---

## 获取用户信息

### 客户端获取

```tsx
'use client';

import { useSession } from 'next-auth/react';

export function UserProfile() {
  const { data: session, status } = useSession();

  if (status === 'loading') {
    return <div>加载中...</div>;
  }

  if (status === 'unauthenticated') {
    return <div>未登录</div>;
  }

  return (
    <div className="flex items-center gap-3">
      <img 
        src={session?.user?.image || '/default-avatar.png'} 
        alt={session?.user?.name || 'User'}
        className="w-10 h-10 rounded-full"
      />
      <div>
        <p className="font-medium">{session?.user?.name}</p>
        <p className="text-sm text-gray-600">{session?.user?.email}</p>
      </div>
    </div>
  );
}
```

### 服务端获取

```tsx
import { getServerSession } from 'next-auth';
import { redirect } from 'next/navigation';

export default async function ProtectedPage() {
  const session = await getServerSession();

  if (!session) {
    redirect('/login');
  }

  return (
    <div>
      <h1>欢迎, {session.user?.name}!</h1>
      <p>邮箱: {session.user?.email}</p>
      <img src={session.user?.image || ''} alt="Avatar" />
    </div>
  );
}
```

### 通过 tRPC 获取

登录后，所有 tRPC 接口自动获得用户身份：

```typescript
// 自动认证
const userState = await trpc.user.getUserState.query();
console.log('用户 ID:', userState.userId);
console.log('邮箱:', userState.email);
```

---

## 退出登录

```tsx
'use client';

import { signOut } from 'next-auth/react';

export function SignOutButton() {
  return (
    <button
      onClick={() => signOut({ callbackUrl: '/' })}
      className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
    >
      退出登录
    </button>
  );
}
```

---

## 权限范围（Scopes）

默认请求的权限：

```typescript
// 在 google.ts 中配置
authorization: {
  params: {
    scope: 'openid https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email'
  }
}
```

**可获取的信息**：
- ✅ 用户 ID
- ✅ 用户名
- ✅ 邮箱地址
- ✅ 头像 URL
- ✅ 邮箱验证状态

**不包含**：
- ❌ Google Drive 访问
- ❌ Gmail 访问
- ❌ 日历访问
- ❌ 联系人访问

如需更多权限，需要在 Google Cloud Console 中额外申请并修改 scope。

---

## 多个 OAuth 提供商组合

### 配置多个提供商

```bash
# .env
NEXT_AUTH_SSO_PROVIDERS=google,github,microsoft

# Google
AUTH_GOOGLE_CLIENT_ID=xxx
AUTH_GOOGLE_CLIENT_SECRET=xxx

# GitHub
AUTH_GITHUB_ID=xxx
AUTH_GITHUB_SECRET=xxx

# Microsoft
AUTH_MICROSOFT_ENTRA_ID_ID=xxx
AUTH_MICROSOFT_ENTRA_ID_SECRET=xxx
AUTH_MICROSOFT_ENTRA_ID_TENANT_ID=xxx
```

### 动态显示可用登录方式

```tsx
'use client';

import { getProviders, signIn } from 'next-auth/react';
import { useEffect, useState } from 'react';

export function DynamicLoginButtons() {
  const [providers, setProviders] = useState<any>(null);

  useEffect(() => {
    (async () => {
      const res = await getProviders();
      setProviders(res);
    })();
  }, []);

  if (!providers) return <div>加载中...</div>;

  return (
    <div className="space-y-3">
      {Object.values(providers).map((provider: any) => (
        <button
          key={provider.id}
          onClick={() => signIn(provider.id, { callbackUrl: '/chat' })}
          className="w-full px-4 py-3 bg-white border rounded-lg hover:bg-gray-50"
        >
          使用 {provider.name} 登录
        </button>
      ))}
    </div>
  );
}
```

---

## 会话管理

### 检查登录状态

```tsx
'use client';

import { useSession } from 'next-auth/react';

export function AuthGuard({ children }: { children: React.ReactNode }) {
  const { status } = useSession({
    required: true,
    onUnauthenticated() {
      window.location.href = '/login';
    },
  });

  if (status === 'loading') {
    return <div>加载中...</div>;
  }

  return <>{children}</>;
}
```

### 会话刷新

```tsx
'use client';

import { useSession } from 'next-auth/react';

export function SessionRefresh() {
  const { data: session, update } = useSession();

  const handleRefresh = async () => {
    // 手动刷新会话
    await update();
  };

  return (
    <button onClick={handleRefresh}>
      刷新会话
    </button>
  );
}
```

### 会话过期处理

```tsx
'use client';

import { useSession } from 'next-auth/react';
import { useEffect } from 'react';
import { useRouter } from 'next/navigation';

export function SessionMonitor() {
  const { data: session, status } = useSession();
  const router = useRouter();

  useEffect(() => {
    if (status === 'unauthenticated') {
      // 会话过期，跳转到登录页
      router.push('/login?expired=true');
    }
  }, [status, router]);

  return null;
}
```

---

## 安全最佳实践

### 1. HTTPS 强制

```nginx
# Nginx 配置
server {
    listen 443 ssl http2;
    
    # 强制 HTTPS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
}
```

### 2. CSRF 保护

NextAuth 自动处理 CSRF 保护，无需额外配置。

### 3. 状态参数验证

OAuth 流程中的 state 参数由 NextAuth 自动生成和验证。

### 4. 回调 URL 白名单

在 Google Cloud Console 中只添加必要的回调 URL：

```
✅ https://yourdomain.com/api/auth/callback/google
✅ http://localhost:3000/api/auth/callback/google (开发环境)
❌ https://*.yourdomain.com/... (避免使用通配符)
```

### 5. 定期轮换密钥

```bash
# 定期更新 NEXT_AUTH_SECRET
openssl rand -base64 32
```

---

## 故障排查

### 问题 1: 回调错误

**错误**: `Error: redirect_uri_mismatch`

**解决**:
1. 检查 Google Cloud Console 中的回调 URL 配置
2. 确保 URL 完全匹配（包括协议、域名、端口）
3. 不要遗漏 `/api/auth/callback/google`

### 问题 2: 无法获取用户信息

**错误**: 登录成功但用户信息为空

**解决**:
1. 检查 scope 配置是否正确
2. 确认 Google+ API 已启用
3. 查看控制台错误日志

### 问题 3: 会话未创建

**错误**: 登录后立即退出

**解决**:
```bash
# 检查 NEXT_AUTH_SECRET 是否设置
echo $NEXT_AUTH_SECRET

# 如果为空，生成并设置
openssl rand -base64 32
```

### 问题 4: CORS 错误

**错误**: `Access-Control-Allow-Origin` 错误

**解决**:
```typescript
// next.config.js
module.exports = {
  async headers() {
    return [
      {
        source: '/api/auth/:path*',
        headers: [
          { key: 'Access-Control-Allow-Credentials', value: 'true' },
          { key: 'Access-Control-Allow-Origin', value: process.env.NEXTAUTH_URL },
        ],
      },
    ];
  },
};
```

---

## 测试

### 测试 OAuth 流程

```typescript
// __tests__/auth.test.ts
import { signIn } from 'next-auth/react';

describe('Google OAuth', () => {
  it('should initiate Google sign in', async () => {
    const result = await signIn('google', { 
      redirect: false,
      callbackUrl: '/chat' 
    });
    
    expect(result).toBeDefined();
    expect(result?.url).toContain('accounts.google.com');
  });
});
```

---

## TypeScript 类型

```typescript
import type { Session } from 'next-auth';

interface GoogleSession extends Session {
  user: {
    id: string;
    name: string;
    email: string;
    image: string;
  };
  expires: string;
}

// 扩展 NextAuth 类型
declare module 'next-auth' {
  interface Session {
    user: {
      id: string;
      name: string;
      email: string;
      image: string;
    };
  }
}
```

---

## 与其他认证方式对比

| 功能 | Google OAuth | Clerk | TronLink |
|------|-------------|-------|----------|
| 无需注册 | ✅ | ❌ | ✅ |
| 邮箱验证 | 自动 | 需要 | 不适用 |
| 用户体验 | 优秀 | 优秀 | 中等 |
| 开发复杂度 | 简单 | 简单 | 中等 |
| 去中心化 | ❌ | ❌ | ✅ |
| 费用 | 免费 | 10k MAU | 免费 |

---

## 相关资源

- [Google OAuth 文档](https://developers.google.com/identity/protocols/oauth2)
- [Google Cloud Console](https://console.cloud.google.com/)
- [NextAuth.js Google 提供商](https://next-auth.js.org/providers/google)
- [认证方式概览](./auth-overview.md)

---

最后更新: 2026-02-14
