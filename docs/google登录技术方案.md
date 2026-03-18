# Google 登录技术方案

## 概述

本文档描述基于 NextAuth.js 框架集成 Google OAuth 登录的技术方案，支持用户使用 Google 账号一键登录应用。

---

## 特点

- ✅ **无需注册**：使用现有 Google 账号直接登录
- ✅ **安全可靠**：基于 OAuth 2.0 标准协议
- ✅ **快速便捷**：一键登录，无需填写表单
- ✅ **自动同步**：自动获取用户头像、昵称、邮箱
- ✅ **跨平台**：支持 Web、移动端
- ✅ **账户绑定**：支持钱包登录用户绑定/解绑 Google 账户

---

## 配置要求

### 1. 创建 Google OAuth 应用

访问 [Google Cloud Console](https://console.cloud.google.com/)：

1. **创建或选择项目**
   - 登录 Google Cloud Console
   - 点击项目选择器，创建新项目或选择现有项目

2. **启用 Google+ API**
   - 转到 **API 和服务** → **库**
   - 搜索 "Google+ API" 或 "Google People API"
   - 点击启用

3. **配置 OAuth 同意屏幕**
   - 转到 **API 和服务** → **OAuth 同意屏幕**
   - 选择用户类型（外部或内部）
   - 填写应用信息：
     - 应用名称
     - 用户支持邮箱
     - 开发者联系信息
   - 添加应用域名和隐私政策链接（生产环境必需）

4. **创建 OAuth 2.0 客户端 ID**
   - 转到 **凭据** → **创建凭据** → **OAuth 2.0 客户端 ID**
   - 选择应用类型：**Web 应用**
   - 填写应用名称
   - 配置授权重定向 URI（见下文）

### 2. 配置回调 URL

在 Google Cloud Console 中添加授权重定向 URI：

```
开发环境：
http://localhost:3000/api/auth/callback/google

测试环境：
https://chat-dev.ainft.com/api/auth/callback/google

生产环境：
https://chat.ainft.com/api/auth/callback/google
```

> ⚠️ **注意**：回调 URL 必须与 NextAuth.js 配置中的 `NEXTAUTH_URL` 一致，包括协议、域名和端口。

### 3. 获取客户端凭据

创建 OAuth 客户端后，获取以下信息：

- **Client ID**: `xxx.apps.googleusercontent.com`
- **Client Secret**: `GOCSPX-xxx`

## 系统架构

### 整体架构图

```mermaid
flowchart TB
    subgraph Client["客户端层"]
        UI["登录界面"]
        NextAuthClient["NextAuth.js 客户端"]
    end

    subgraph NextApp["Next.js 应用层"]
        NextAuthAPI["/api/auth/[...nextauth]"]
        AdapterAPI["/api/auth/adapter"]
        AuthConfig["NextAuth 配置"]
        GoogleProvider["Google Provider"]
    end

    subgraph Service["服务层"]
        UserService["NextAuthUserService"]
        WalletService["钱包同步服务"]
    end

    subgraph Data["数据层"]
        UserModel["UserModel"]
        WalletModel["UserWalletModel"]
        DB[("PostgreSQL")]
    end

    subgraph External["外部服务"]
        GoogleOAuth["Google OAuth 2.0"]
        PostHog["PostHog 分析"]
    end

    UI --> NextAuthClient
    NextAuthClient --> NextAuthAPI
    NextAuthAPI --> AuthConfig
    AuthConfig --> GoogleProvider
    NextAuthAPI --> GoogleOAuth
    NextAuthAPI --> AdapterAPI
    AdapterAPI --> UserService
    UserService --> UserModel
    UserService --> WalletService
    WalletService --> WalletModel
    UserModel --> DB
    WalletModel --> DB
    UserService -.-> PostHog
```

---

## OAuth 登录流程

### 完整时序图

```mermaid
sequenceDiagram
    autonumber
    actor User as 用户
    participant Browser as 浏览器
    participant Frontend as 前端应用
    participant NextAuth as NextAuth.js
    participant Google as Google OAuth
    participant Adapter as Adapter API
    participant Service as UserService
    participant DB as 数据库
    participant PostHog as PostHog

    User->>Frontend: 点击"使用 Google 登录"
    Frontend->>NextAuth: signIn('google')
    NextAuth->>Browser: 重定向到 Google 授权页
    Browser->>Google: GET /oauth2/v2/auth
    Google->>User: 显示授权页面
    User->>Google: 选择账号并授权
    Google->>Browser: 重定向到回调地址
    Browser->>NextAuth: GET /api/auth/callback/google?code=xxx
    NextAuth->>Google: 交换授权码获取 Token
    Google-->>NextAuth: 返回 Access Token + ID Token
    NextAuth->>Google: 获取用户信息
    Google-->>NextAuth: 返回用户资料
    
    alt 用户不存在
        NextAuth->>Adapter: createUser
        Adapter->>Service: createUser
        Service->>DB: 插入用户记录
        DB-->>Service: 返回新用户
        Service->>PostHog: 发送 user_signup 事件
        Service->>PostHog: 发送 user_login 事件
        Service-->>Adapter: 返回用户数据
        Adapter-->>NextAuth: 返回 AdapterUser
    else 用户已存在
        NextAuth->>Adapter: getUserByAccount
        Adapter->>Service: getUserByAccount
        Service->>DB: 查询用户
        DB-->>Service: 返回用户
        Service->>PostHog: 发送 user_login 事件
        Service-->>Adapter: 返回用户数据
        Adapter-->>NextAuth: 返回 AdapterUser
    end

    NextAuth->>Adapter: linkAccount
    Adapter->>Service: linkAccount
    Service->>DB: 关联 OAuth 账号
    Service->>DB: 同步到 userWallet 表
    Adapter-->>NextAuth: 完成

    NextAuth->>Adapter: createSession
    Adapter->>Service: createSession
    Service->>DB: 创建会话记录
    Adapter-->>NextAuth: 返回 Session

    NextAuth-->>Browser: 设置 Session Cookie
    Browser-->>Frontend: 重定向到 /chat
    Frontend-->>User: 登录成功，进入应用
```

---

## 组件设计

### Provider 架构

```mermaid
flowchart LR
    subgraph Providers["SSO Providers"]
        direction TB
        Github["GitHub"]
        Google["Google"]
        Binance["Binance"]
        OKX["OKX"]
        MetaMask["MetaMask"]
        TronLink["TronLink"]
        TokenPocket["TokenPocket"]
        Bybit["Bybit"]
        Others["...其他"]
    end

    subgraph Config["配置中心"]
        SSOConfig["SSO Config"]
        AuthConfig["Auth Config"]
    end

    subgraph Runtime["运行时"]
        Init["initSSOProviders"]
        NextAuth["NextAuth"]
    end

    Google --> SSOConfig
    Github --> SSOConfig
    Binance --> SSOConfig
    OKX --> SSOConfig
    MetaMask --> SSOConfig
    TronLink --> SSOConfig
    TokenPocket --> SSOConfig
    Bybit --> SSOConfig
    Others --> SSOConfig
    
    SSOConfig --> Init
    Init --> AuthConfig
    AuthConfig --> NextAuth
```

### Google Provider 配置

```mermaid
flowchart LR
    subgraph GoogleProvider["Google Provider"]
        direction TB
        ClientID["clientId"]
        ClientSecret["clientSecret"]
        Authorization["authorization.params.scope"]
    end

    subgraph Scopes["请求权限"]
        OpenID["openid"]
        Profile["userinfo.profile"]
        Email["userinfo.email"]
    end

    subgraph UserInfo["获取信息"]
        ID["用户 ID"]
        Name["用户名"]
        Email["邮箱地址"]
        Avatar["头像 URL"]
        Verified["邮箱验证状态"]
    end

    Authorization --> Scopes
    Scopes --> UserInfo
```

---


---

## 用户数据处理流程

### 新用户注册流程

```mermaid
flowchart TB
    Start(["开始"]) --> Receive["接收 Google 用户信息"]
    Receive --> CheckExist{"用户是否存在?"}
    
    CheckExist -->|否| CreateUser["创建用户"]
    CreateUser --> CaptureSignup["PostHog: user_signup"]
    CaptureSignup --> CaptureLogin["PostHog: user_login"]
    CaptureLogin --> LinkAccount["关联 OAuth 账号"]
    
    CheckExist -->|是| GetUser["获取用户"]
    GetUser --> CaptureLogin2["PostHog: user_login"]
    CaptureLogin2 --> LinkAccount
    
    LinkAccount --> SyncWallet{"是钱包 Provider?"}
    SyncWallet -->|是| CreateWallet["同步到 userWallet"]
    SyncWallet -->|否| CreateSession
    CreateWallet --> CreateSession["创建 Session"]
    CreateSession --> EndFlow(["结束"])
```

### 用户信息映射

```mermaid
flowchart LR
    subgraph GoogleData["Google 返回数据"]
        GSub["sub"]
        GName["name"]
        GPicture["picture"]
        GVerified["email_verified"]
    end

    subgraph UserFields["用户字段"]
        UId["id"]
        UUsername["username"]
        UEmail["email"]
        UAvatar["avatar"]
    end

    GSub -->|映射为| UId
    GName -->|映射为| UUsername
    GPicture -->|映射为| UAvatar
    GVerified -->|映射为| UEmail
```

---

## 钱包用户绑定/解绑 Google 账户

### 功能概述

支持已使用钱包登录的用户绑定 Google 账户，实现多方式登录。用户可以在个人资料页面管理已绑定的 SSO 提供商。

### 绑定流程架构

```mermaid
flowchart TB
    subgraph WalletUser["钱包登录用户"]
        direction TB
        WalletLogin["钱包登录状态"]
        ProfilePage["个人资料页"]
    end

    subgraph BindFlow["绑定流程"]
        direction TB
        ClickBind["点击绑定 Google"]
        OAuthFlow["OAuth 授权流程"]
        LinkAccount["linkAccount 关联账户"]
    end

    subgraph DataLayer["数据层"]
        UserTable["users 表"]
        AccountTable["nextauth_accounts 表"]
    end

    WalletLogin --> ProfilePage
    ProfilePage --> ClickBind
    ClickBind --> OAuthFlow
    OAuthFlow --> LinkAccount
    LinkAccount --> AccountTable
    AccountTable --> UserTable
```

### 绑定流程时序图

```mermaid
sequenceDiagram
    autonumber
    actor User as 用户(已钱包登录)
    participant Profile as 个人资料页
    participant NextAuth as NextAuth.js
    participant Google as Google OAuth
    participant Adapter as Adapter API
    participant Service as NextAuthUserService
    participant DB as 数据库

    User->>Profile: 点击"绑定 Google"
    Profile->>NextAuth: signIn('google', { redirect: false })
    Note over NextAuth: 设置 redirect: false<br/>保持在当前页面
    
    NextAuth->>Google: 重定向到授权页
    Google->>User: 选择 Google 账号
    User->>Google: 授权
    Google->>NextAuth: 回调 /api/auth/callback/google
    
    NextAuth->>Google: 获取用户信息
    Google-->>NextAuth: 返回用户资料
    
    NextAuth->>Adapter: getUserByAccount
    Adapter->>Service: getUserByAccount
    Service->>DB: 查询是否已存在
    DB-->>Service: 返回查询结果
    
    alt Google 账户未绑定
        NextAuth->>Adapter: linkAccount
        Adapter->>Service: linkAccount
        Service->>DB: 插入 nextauth_accounts 记录
        DB-->>Service: 返回成功
        Service-->>Adapter: 返回 AdapterAccount
        Adapter-->>NextAuth: 完成
        NextAuth-->>Profile: 返回 { ok: true }
        Profile-->>User: 显示绑定成功
    else Google 账户已绑定其他用户
        NextAuth-->>Profile: 返回错误
        Profile-->>User: 显示"该 Google 账户已被绑定"
    end
```

### 解绑流程时序图

```mermaid
sequenceDiagram
    autonumber
    actor User as 用户
    participant Profile as 个人资料页
    participant UserService as UserService
    participant UserRouter as UserRouter
    participant NextAuthService as NextAuthUserService
    participant DB as 数据库

    User->>Profile: 点击解绑 Google
    Profile->>Profile: 检查 SSO 提供商数量
    
    alt 至少保留一个登录方式
        Profile->>UserService: unlinkSSOProvider(provider, providerAccountId)
        UserService->>UserRouter: unlinkSSOProvider.mutate
        UserRouter->>NextAuthService: unlinkAccount
        NextAuthService->>DB: DELETE FROM nextauth_accounts
        DB-->>NextAuthService: 返回成功
        NextAuthService-->>UserRouter: 完成
        UserRouter-->>UserService: 返回成功
        UserService-->>Profile: 返回成功
        Profile-->>User: 显示解绑成功
    else 只有一个登录方式
        Profile-->>User: 显示"至少保留一个登录方式"
    end
```

### 数据模型关系

#### 表结构说明

| 表名 | 物理表名 | 说明 |
|------|----------|------|
| `users` | `users` | 用户主表，存储用户基本信息 |
| `nextauth_accounts` | `nextauth_accounts` | NextAuth 账户表，存储 OAuth 提供商关联信息 |
| `userWallet` | `t_user_wallet` | 用户钱包表，存储绑定的区块链钱包地址 |

#### ER 关系图

```mermaid
erDiagram
    users {
        string id PK "用户唯一标识，格式：user_xxx"
        string username "用户名"
        string email "邮箱地址"
        string avatar "头像 URL"
        string phone "手机号"
        string firstName "名"
        string lastName "姓"
        string fullName "全名"
        boolean isOnboarded "是否完成引导"
        timestamp emailVerifiedAt "邮箱验证时间"
        timestamp createdAt "创建时间"
        timestamp updatedAt "更新时间"
    }
    
    nextauth_accounts {
        string userId FK "关联 users.id，级联删除"
        string type "账户类型：oauth"
        string provider "提供商：google, tronlink, binance..."
        string providerAccountId "提供商账户ID"
        string access_token "访问令牌"
        string refresh_token "刷新令牌"
        int expires_at "令牌过期时间戳"
        string token_type "令牌类型"
        string scope "权限范围"
        string id_token "ID 令牌"
        string session_state "会话状态"
    }
    
    t_user_wallet {
        int id PK "自增主键"
        string userId FK "关联 users.id"
        string chain "链类型：tron, bnb, eth..."
        string address "钱包地址"
        timestamp createdAt "创建时间"
        timestamp updatedAt "更新时间"
    }

    users ||--o{ nextauth_accounts : "一个用户可有多个 OAuth 账户"
    users ||--o{ t_user_wallet : "一个用户可绑定多个钱包"
```

#### 关联关系详解

**1. users 表与 nextauth_accounts 表**

- **关联字段**: `nextauth_accounts.userId` → `users.id`
- **关联类型**: 一对多（一个用户可有多个 OAuth 账户）
- **级联操作**: `onDelete: 'cascade'` - 删除用户时自动删除关联的 OAuth 账户
- **联合主键**: (`provider`, `providerAccountId`) 确保同一提供商账户只能绑定一个用户

**2. nextauth_accounts 表索引**

| 索引名称 | 类型 | 字段 | 说明 |
|----------|------|------|------|
| `compositePk` | 联合主键 | (`provider`, `providerAccountId`) | 确保同一提供商的同一账户只能绑定一个用户 |


**3. users 表与 t_user_wallet 表**

- **关联字段**: `t_user_wallet.userId` → `users.id`
- **关联类型**: 一对多（一个用户可绑定多个链的钱包）
- **唯一约束**: 
  - `(userId, chain)` - 每个用户在每个链上只能绑定一个地址
  - `(address, chain)` - 同一地址在同一链上只能被一个用户绑定

#### 典型数据示例

**场景：用户通过钱包登录后绑定 Google**

```
users 表:
┌─────────────────┬───────────┬──────────────────┐
│ id              │ username  │ email            │
├─────────────────┼───────────┼──────────────────┤
│ user_abc123     │ john_doe  │ john@gmail.com   │
└─────────────────┴───────────┴──────────────────┘

nextauth_accounts 表（2条记录）:
┌─────────────┬───────────┬─────────────────────────┬─────────────────────────┐
│ userId      │ provider  │ providerAccountId       │ type                    │
├─────────────┼───────────┼─────────────────────────┼─────────────────────────┤
│ user_abc123 │ tronlink  │ tron:TXxxxxx...         │ oauth                   │
│ user_abc123 │ google    │ 123456789               │ oauth                   │
└─────────────┴───────────┴─────────────────────────┴─────────────────────────┘

t_user_wallet 表:
┌────┬─────────────┬───────┬────────────────────────────────────────┐
│ id │ userId      │ chain │ address                                │
├────┼─────────────┼───────┼────────────────────────────────────────┤
│ 1  │ user_abc123 │ tron  │ TXxxxxx...                             │
└────┴─────────────┴───────┴────────────────────────────────────────┘
```


## 相关资源

- [Google OAuth 文档](https://developers.google.com/identity/protocols/oauth2)
- [Google Cloud Console](https://console.cloud.google.com/)
- [NextAuth.js Google 提供商](https://next-auth.js.org/providers/google)
- [认证方式概览](../api/RESTful/auth-overview.md)
- [Wallet 钱包管理接口](../api/tRPC/lambda/wallet.md)

---

最后更新: 2026-03-17
