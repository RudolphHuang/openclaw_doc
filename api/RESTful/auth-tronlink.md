# TronLink 登录接口

TronLink 是基于 Web3 钱包的去中心化登录方式，使用 TRON 区块链地址作为用户身份。

## 登录流程

TronLink 登录采用标准的 Web3 钱包签名认证流程：

```
1. 获取 CSRF Token
   ↓
2. 连接 TronLink 钱包
   ↓
3. 生成签名消息（SIWE 格式）
   ↓
4. 用户使用钱包签名
   ↓
5. 提交签名到后端验证
   ↓
6. 后端验证签名并创建会话
   ↓
7. 返回认证结果和跳转 URL
```

---

## 1. 获取 CSRF Token

### GET /api/auth/csrf

获取 CSRF Token，用于防止跨站请求伪造攻击。

**方法**: `GET`

**路径**: `/api/auth/csrf`

**认证**: 无需认证

**请求头**:

```http
Accept: */*
Content-Type: application/json
```

**响应**:

```typescript
{
  csrfToken: string;  // CSRF Token
}
```

**示例**:

```typescript
const response = await fetch('/api/auth/csrf', {
  method: 'GET',
  headers: {
    'Accept': '*/*',
    'Content-Type': 'application/json'
  }
});

const { csrfToken } = await response.json();
console.log('CSRF Token:', csrfToken);
```

---

## 2. TronLink 登录回调

### POST /api/auth/callback/tronlink

提交 TronLink 签名进行认证。

**方法**: `POST`

**路径**: `/api/auth/callback/tronlink?`

**认证**: 需要 CSRF Token

**Content-Type**: `application/x-www-form-urlencoded`

**请求头**:

```http
Content-Type: application/x-www-form-urlencoded
X-Auth-Return-Redirect: 1
```

**请求体（URL 编码）**:

```typescript
{
  message: string;       // SIWE 格式的签名消息（URL 编码）
  signature: string;     // TronLink 签名（十六进制，带 0x 前缀）
  version: number;       // 签名版本（1 或 2）
  csrfToken: string;     // 从 /api/auth/csrf 获取的 Token
  callbackUrl: string;   // 登录成功后的回调 URL（URL 编码）
}
```

**SIWE 消息格式**:

```
Welcome to AINFT !
https://chat-dev.ainft.com wants you to sign in with your TRON account:
TXaACc4QjRWJQefuHsGYApDG1UXzJQtJj3

Chain ID: 0x94a9059e
Expiration Time: 2026-02-15T05:40:56.842Z
Nonce: DR6DA31771047651842
```

**响应**:

当设置 `X-Auth-Return-Redirect: 1` 时，返回 JSON：

```typescript
{
  url: string;  // 重定向 URL
}
```

否则返回 HTTP 302 重定向。

**错误响应**:

```typescript
{
  error: string;
  url?: string;  // 错误页面 URL
}
```

---

## 完整的前端实现示例

### 使用 TronLink 登录

```typescript
import { useRouter } from 'next/navigation';

async function loginWithTronLink() {
  try {
    // 检查 TronLink 是否安装
    if (!window.tronLink) {
      alert('请先安装 TronLink 钱包扩展');
      return;
    }

    // 1. 请求连接钱包
    const tronWeb = window.tronLink;
    const connected = await tronWeb.request({ method: 'tron_requestAccounts' });
    
    if (!connected) {
      alert('钱包连接失败');
      return;
    }

    // 2. 获取当前地址
    const address = tronWeb.tronWeb.defaultAddress.base58;
    console.log('钱包地址:', address);

    // 3. 获取 CSRF Token
    const csrfResponse = await fetch('/api/auth/csrf');
    const { csrfToken } = await csrfResponse.json();

    // 4. 生成签名消息（SIWE 格式）
    const domain = window.location.host;
    const origin = window.location.origin;
    const chainId = '0x94a9059e'; // TRON 主网 Chain ID
    const expirationTime = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();
    const nonce = generateNonce(); // 生成随机 nonce

    const message = `Welcome to AINFT !
${origin} wants you to sign in with your TRON account:
${address}

Chain ID: ${chainId}
Expiration Time: ${expirationTime}
Nonce: ${nonce}`;

    // 5. 请求用户签名
    const signature = await tronWeb.tronWeb.trx.sign(
      tronWeb.tronWeb.toHex(message)
    );

    console.log('签名成功:', signature);

    // 6. 提交签名到后端
    const callbackUrl = '/chat?session=inbox'; // 登录成功后的跳转页面

    const formData = new URLSearchParams();
    formData.append('message', message);
    formData.append('signature', signature);
    formData.append('version', '2');
    formData.append('csrfToken', csrfToken);
    formData.append('callbackUrl', callbackUrl);

    const loginResponse = await fetch('/api/auth/callback/tronlink?', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-Auth-Return-Redirect': '1'
      },
      body: formData.toString()
    });

    const result = await loginResponse.json();

    if (loginResponse.ok) {
      // 7. 登录成功，跳转
      console.log('登录成功，跳转到:', result.url);
      window.location.href = result.url;
    } else {
      // 登录失败
      console.error('登录失败:', result.error);
      alert(`登录失败: ${result.error}`);
    }

  } catch (error) {
    console.error('TronLink 登录错误:', error);
    alert(`登录失败: ${error.message}`);
  }
}

// 生成随机 nonce
function generateNonce() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let nonce = '';
  for (let i = 0; i < 20; i++) {
    nonce += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return nonce + Date.now();
}
```

### 使用 React Hook

```typescript
import { useState } from 'react';

export function useTronLinkAuth() {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const login = async (callbackUrl = '/chat?session=inbox') => {
    setLoading(true);
    setError(null);

    try {
      if (!window.tronLink) {
        throw new Error('请先安装 TronLink 钱包');
      }

      const tronWeb = window.tronLink;
      
      // 连接钱包
      const connected = await tronWeb.request({ 
        method: 'tron_requestAccounts' 
      });
      
      if (!connected) {
        throw new Error('钱包连接失败');
      }

      const address = tronWeb.tronWeb.defaultAddress.base58;

      // 获取 CSRF Token
      const csrfRes = await fetch('/api/auth/csrf');
      const { csrfToken } = await csrfRes.json();

      // 生成消息
      const message = createSIWEMessage(address);

      // 签名
      const signature = await tronWeb.tronWeb.trx.sign(
        tronWeb.tronWeb.toHex(message)
      );

      // 提交登录
      const formData = new URLSearchParams({
        message,
        signature,
        version: '2',
        csrfToken,
        callbackUrl
      });

      const res = await fetch('/api/auth/callback/tronlink?', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-Auth-Return-Redirect': '1'
        },
        body: formData.toString()
      });

      const result = await res.json();

      if (res.ok) {
        window.location.href = result.url;
      } else {
        throw new Error(result.error || '登录失败');
      }

    } catch (err) {
      const message = err instanceof Error ? err.message : '登录失败';
      setError(message);
      console.error('TronLink 登录错误:', err);
    } finally {
      setLoading(false);
    }
  };

  return { login, loading, error };
}

function createSIWEMessage(address: string) {
  const domain = window.location.host;
  const origin = window.location.origin;
  const chainId = '0x94a9059e';
  const expirationTime = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();
  const nonce = `NONCE${Date.now()}${Math.random().toString(36).substr(2, 9)}`;

  return `Welcome to AINFT !
${origin} wants you to sign in with your TRON account:
${address}

Chain ID: ${chainId}
Expiration Time: ${expirationTime}
Nonce: ${nonce}`;
}
```

### React 组件示例

```tsx
import { useTronLinkAuth } from './useTronLinkAuth';

export function TronLinkLoginButton() {
  const { login, loading, error } = useTronLinkAuth();

  return (
    <div>
      <button 
        onClick={() => login()}
        disabled={loading}
        className="btn-primary"
      >
        {loading ? '连接中...' : '使用 TronLink 登录'}
      </button>
      
      {error && (
        <div className="error-message">
          {error}
        </div>
      )}
    </div>
  );
}
```

---

## 签名版本说明

### Version 1

使用 `tronWeb.trx.sign()` 方法签名原始消息字符串。

```typescript
const signature = await tronWeb.trx.sign(message);
```

### Version 2 (推荐)

使用 `tronWeb.trx.sign()` 签名消息的十六进制编码。

```typescript
const signature = await tronWeb.trx.sign(
  tronWeb.toHex(message)
);
```

**建议使用 Version 2**，因为它与标准的 EIP-191 签名格式更兼容。

---

## 安全注意事项

### 1. CSRF 保护

- 每次登录前必须获取新的 CSRF Token
- CSRF Token 与用户会话绑定
- Token 有时效性（通常 30 分钟）

### 2. 消息格式

- 使用标准的 SIWE（Sign-In with Ethereum）格式
- 包含域名、地址、Chain ID、过期时间、Nonce
- 防止签名被重放攻击

### 3. 签名验证

后端会验证：
- 签名是否有效
- 地址是否与签名匹配
- 消息格式是否正确
- 过期时间是否有效
- Nonce 是否已使用

### 4. 会话管理

- 登录成功后自动创建用户会话
- 会话通过 Cookie 管理（HttpOnly、Secure）
- 支持会话持久化

---

## 错误处理

### 常见错误

```typescript
// 1. 钱包未安装
if (!window.tronLink) {
  alert('请安装 TronLink 钱包扩展');
  return;
}

// 2. 用户拒绝连接
try {
  await tronWeb.request({ method: 'tron_requestAccounts' });
} catch (error) {
  if (error.code === 4001) {
    alert('您拒绝了连接请求');
  }
}

// 3. 用户拒绝签名
try {
  const signature = await tronWeb.trx.sign(message);
} catch (error) {
  alert('您拒绝了签名请求');
}

// 4. 签名验证失败
if (!loginResponse.ok) {
  const { error } = await loginResponse.json();
  if (error.includes('Invalid signature')) {
    alert('签名验证失败，请重试');
  }
}
```

---

## TronLink API 参考

### 检测钱包

```typescript
if (typeof window.tronLink !== 'undefined') {
  console.log('TronLink 已安装');
}
```

### 请求连接

```typescript
const result = await window.tronLink.request({
  method: 'tron_requestAccounts'
});
// result: true/false
```

### 获取账户地址

```typescript
const address = window.tronLink.tronWeb.defaultAddress.base58;
console.log('地址:', address); // 如: TXaACc4QjRWJQefuHsGYApDG1UXzJQtJj3
```

### 签名消息

```typescript
// 签名文本消息
const signature = await window.tronLink.tronWeb.trx.sign(message);

// 签名十六进制消息
const hexMessage = window.tronLink.tronWeb.toHex(message);
const signature = await window.tronLink.tronWeb.trx.sign(hexMessage);
```

### 监听账户变化

```typescript
window.addEventListener('message', (e) => {
  if (e.data.message && e.data.message.action === 'setAccount') {
    console.log('账户已切换:', e.data.message.data.address);
    // 重新登录
  }
});
```

---

## 与后端 tRPC 接口的关系

登录成功后，用户身份会通过 JWT Token 在后端验证。所有需要认证的 tRPC 接口都会自动验证登录状态。

```typescript
// 登录后自动获取用户状态
const userState = await trpc.user.getUserState.query();
console.log('用户 ID:', userState.userId); // TronLink 地址
console.log('是否登录:', !!userState.userId);

// 所有认证接口都可以正常使用
const sessions = await trpc.session.getSessions.query();
```

---

## 测试账户

开发环境可以使用 TronLink 测试网：

1. 切换到 Nile 测试网
2. 从水龙头获取测试 TRX
3. 使用测试账户登录

---

## 相关文档

- [用户管理接口](../tRPC/lambda/user.md) - 获取用户状态、更新设置
- [积分奖励](../tRPC/lambda/user.md#积分奖励相关) - 登录后领取注册奖励

---

## TypeScript 类型定义

```typescript
interface TronLink {
  ready: boolean;
  tronWeb: {
    defaultAddress: {
      base58: string;
      hex: string;
    };
    trx: {
      sign(message: string): Promise<string>;
      signMessage(message: string): Promise<string>;
    };
    toHex(str: string): string;
  };
  request(args: { method: string }): Promise<any>;
}

interface Window {
  tronLink?: TronLink;
}

interface AuthResponse {
  url: string;
}

interface AuthError {
  error: string;
  url?: string;
}
```

---

最后更新: 2026-02-14
