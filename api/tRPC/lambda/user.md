# User 用户管理接口

用户信息管理、设置、偏好、SSO 账户关联、积分奖励等功能。

## 接口列表

### getUserState

获取当前用户状态和初始化信息。

**类型**: `query`

**权限**: 需要认证（authedProcedure）

**输入参数**: 无

**返回数据**:

```typescript
{
  userId: string;
  username: string | null;
  email: string | null;
  avatar: string | null;
  firstName: string | null;
  lastName: string | null;
  fullName: string | null;
  isOnboard: boolean;
  hasConversation: boolean;
  canEnablePWAGuide: boolean;
  canEnableTrace: boolean;
  preference: UserPreference;
  settings: UserSettings;
}
```

**说明**:

- 如果用户不存在，会自动创建用户（Clerk 模式或桌面模式）
- `canEnablePWAGuide`: 当消息数 > 4 时可启用 PWA 引导
- `canEnableTrace`: 当消息数 > 4 时可启用追踪
- `hasConversation`: 有消息或创建过助手则为 true

---

### getUserRegistrationDuration

获取用户注册时长。

**类型**: `query`

**权限**: 需要认证

**输入参数**: 无

**返回数据**: 

```typescript
number // 注册天数
```

---

### getUserSSOProviders

获取用户已关联的 SSO 提供商列表。

**类型**: `query`

**权限**: 需要认证

**输入参数**: 无

**返回数据**:

```typescript
Array<{
  provider: string;
  providerAccountId: string;
}>
```

---

### updateSettings

更新用户设置。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  keyVaults?: object;  // 密钥库（会加密存储）
  [key: string]: any;  // 其他设置字段
}
```

**返回数据**: 

```typescript
void
```

**说明**:

- `keyVaults` 会使用服务端密钥加密后存储
- 其他设置字段会直接存储

---

### updatePreference

更新用户偏好设置。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
any // UserPreference 对象
```

**返回数据**: 

```typescript
void
```

---

### updateGuide

更新用户引导状态。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  // UserGuide 字段
  [key: string]: boolean;
}
```

**返回数据**: 

```typescript
void
```

---

### updateAvatar

更新用户头像。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
string // 头像 URL 或 Base64 数据
```

**返回数据**: 

```typescript
void
```

**说明**:

- 支持直接 URL 或 Base64 格式（`data:image/...`）
- Base64 数据会自动上传到 S3 并生成唯一文件名
- 会自动删除旧头像文件

---

### makeUserOnboarded

标记用户已完成引导。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**: 无

**返回数据**: 

```typescript
void
```

---

### resetSettings

重置用户设置为默认值。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**: 无

**返回数据**: 

```typescript
void
```

---

### unlinkSSOProvider

取消关联 SSO 提供商。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  provider: string;
  providerAccountId: string;
}
```

**返回数据**: 

```typescript
void
```

**错误**:

- `NOT_FOUND`: 账户不存在或不属于当前用户

---

## 积分奖励相关

### hasClaimedSignupBonus

查询用户是否已领取注册奖励积分。

**类型**: `query`

**权限**: 需要认证

**输入参数**: 无

**返回数据**:

```typescript
{
  hasClaimed: boolean;
}
```

---

### claimSignupBonus

领取注册奖励积分（需要 TronLink 签名验证）。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  encryptedToken: string;  // 加密的 token（通过单独接口获取）
  message: string;         // TronLink 签名的消息
  signature: string;       // TronLink 签名
  version?: 1 | 2;         // 签名版本，默认 2
}
```

**返回数据**:

```typescript
{
  success: boolean;
  amount?: number;  // 成功时返回奖励积分数（1,000,000）
  message?: string; // 失败时返回提示信息
}
```

**说明**:

- 每个用户只能领取一次
- 需要提供浏览器 User-Agent 和 Referer 头
- 需要 TronLink 签名验证（userId 必须是 Tron 地址）
- 有 IP 限制：1 小时内单 IP 最多赠送 5 次
- 总发放数量限制：600,000 次
- Token 有效期：5 分钟

**错误**:

- `UNAUTHORIZED`: 用户未认证
- `BAD_REQUEST`: 缺少必要请求头、已领取、IP 限制、签名无效等

---

## 使用示例

### 获取用户状态

```typescript
const userState = await trpc.user.getUserState.query();

console.log(userState.userId);
console.log(userState.hasConversation);
```

### 更新用户设置

```typescript
await trpc.user.updateSettings.mutate({
  keyVaults: {
    openai: { apiKey: 'sk-...' }
  },
  theme: 'dark',
  language: 'zh-CN'
});
```

### 更新头像

```typescript
// 使用 URL
await trpc.user.updateAvatar.mutate('https://example.com/avatar.png');

// 使用 Base64
await trpc.user.updateAvatar.mutate('data:image/png;base64,iVBORw0KG...');
```

### 领取注册奖励

```typescript
// 1. 先获取 token（假设通过其他接口获取）
const encryptedToken = getClaimToken();

// 2. 使用 TronLink 签名
const message = `请签名以验证您的 Tron 地址所有权\n时间戳: ${Date.now()}`;
const signature = await window.tronLink.sign(message);

// 3. 领取奖励
const result = await trpc.user.claimSignupBonus.mutate({
  encryptedToken,
  message,
  signature,
  version: 2
});

if (result.success) {
  console.log(`成功领取 ${result.amount} 积分`);
}
```

---

## 数据类型

### UserSettings

```typescript
{
  keyVaults?: string;  // 加密的密钥库
  defaultAgent?: string;
  fontSize?: number;
  language?: string;
  themeMode?: 'auto' | 'light' | 'dark';
  // ... 其他设置字段
}
```

### UserPreference

```typescript
{
  guide?: object;
  telemetry?: boolean;
  // ... 其他偏好字段
}
```
