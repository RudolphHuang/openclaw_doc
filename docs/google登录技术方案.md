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

---

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

## 数据流架构

### Adapter 数据流

```mermaid
flowchart TB
    subgraph NextAuthActions["NextAuth 操作"]
        CreateUser["createUser"]
        GetUserByAccount["getUserByAccount"]
        LinkAccount["linkAccount"]
        CreateSession["createSession"]
    end

    subgraph AdapterLayer["Adapter 层"]
        LobeAdapter["LobeNextAuthDbAdapter"]
    end

    subgraph APILayer["API 层"]
        AdapterRoute["/api/auth/adapter"]
        AuthCheck["Authorization 校验"]
    end

    subgraph ServiceLayer["Service 层"]
        NextAuthUserService["NextAuthUserService"]
    end

    subgraph DataLayer["数据层"]
        UserModel["UserModel"]
        WalletModel["UserWalletModel"]
        SessionModel["SessionModel"]
        AccountModel["AccountModel"]
    end

    CreateUser --> LobeAdapter
    GetUserByAccount --> LobeAdapter
    LinkAccount --> LobeAdapter
    CreateSession --> LobeAdapter

    LobeAdapter --> AdapterRoute
    AdapterRoute --> AuthCheck
    AuthCheck --> NextAuthUserService

    NextAuthUserService --> UserModel
    NextAuthUserService --> WalletModel
    NextAuthUserService --> SessionModel
    NextAuthUserService --> AccountModel
```

---

## 会话管理

### Session 策略对比

```mermaid
flowchart TB
    subgraph JWTStrategy["JWT 策略"]
        JWT["JWT Token"]
        JWTCookie["Session Cookie"]
        ClientSide["客户端存储"]
    end

    subgraph DatabaseStrategy["Database 策略"]
        DBSession["数据库会话"]
        SessionToken["Session Token"]
        ServerSide["服务端存储"]
    end

    subgraph Config["配置条件"]
        ServerEnabled["NEXT_PUBLIC_ENABLED_SERVER_SERVICE"]
        Strategy["NEXT_AUTH_SSO_SESSION_STRATEGY"]
    end

    ServerEnabled -->|false| JWTStrategy
    ServerEnabled -->|true| Strategy
    Strategy -->|jwt| JWTStrategy
    Strategy -->|database| DatabaseStrategy
```

### Session 生命周期

```mermaid
sequenceDiagram
    participant Client as 客户端
    participant NextAuth as NextAuth.js
    participant Adapter as Adapter
    participant DB as 数据库

    Note over Client,DB: 登录流程
    NextAuth->>Adapter: createSession
    Adapter->>DB: INSERT session
    DB-->>Adapter: 返回 session
    Adapter-->>NextAuth: AdapterSession
    NextAuth-->>Client: Set-Cookie: session=xxx

    Note over Client,DB: 请求验证
    Client->>NextAuth: 请求 API (携带 Cookie)
    alt JWT 策略
        NextAuth->>NextAuth: 验证 JWT 签名
    else Database 策略
        NextAuth->>Adapter: getSessionAndUser
        Adapter->>DB: SELECT session
        DB-->>Adapter: 返回 session
        Adapter-->>NextAuth: 验证通过
    end
    NextAuth-->>Client: 返回数据

    Note over Client,DB: 登出流程
    Client->>NextAuth: signOut()
    NextAuth->>Adapter: deleteSession
    Adapter->>DB: DELETE session
    NextAuth-->>Client: 清除 Cookie
```

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
        GEmail["email"]
        GPicture["picture"]
        GVerified["email_verified"]
    end

    subgraph UserFields["用户字段"]
        UId["id"]
        UUsername["username"]
        UEmail["email"]
        UAvatar["avatar"]
        UProvider["provider"]
    end

    GSub -->|映射为| UId
    GName -->|映射为| UUsername
    GEmail -->|映射为| UEmail
    GPicture -->|映射为| UAvatar
    GVerified -.->|验证| UEmail
```

---

## 配置管理

### 环境变量配置

```mermaid
flowchart TB
    subgraph EnvConfig["环境变量配置"]
        EnableAuth["NEXT_PUBLIC_ENABLE_NEXT_AUTH=1"]
        Secret["NEXT_AUTH_SECRET"]
        Providers["NEXT_AUTH_SSO_PROVIDERS"]
        GoogleClientID["AUTH_GOOGLE_CLIENT_ID"]
        GoogleClientSecret["AUTH_GOOGLE_CLIENT_SECRET"]
    end

    subgraph K8sConfig["Kubernetes ConfigMap"]
        ConfigMap["configmap.yml"]
    end

    subgraph Runtime["运行时"]
        AuthConfig["Auth Config"]
        GoogleProvider["Google Provider"]
    end

    EnableAuth --> AuthConfig
    Secret --> AuthConfig
    Providers --> AuthConfig
    GoogleClientID --> K8sConfig
    GoogleClientSecret --> K8sConfig
    K8sConfig --> GoogleProvider
    AuthConfig --> GoogleProvider
```

---

## 安全设计

### 安全机制

```mermaid
flowchart TB
    subgraph Security["安全机制"]
        direction TB
        
        subgraph OAuthSecurity["OAuth 安全"]
            StateParam["State 参数验证"]
            PKCE["PKCE 扩展"]
            HTTPS["HTTPS 强制"]
        end

        subgraph AdapterSecurity["Adapter 安全"]
            AuthHeader["Authorization Header"]
            KVSecret["KEY_VAULTS_SECRET 校验"]
        end

        subgraph SessionSecurity["会话安全"]
            HttpOnly["HttpOnly Cookie"]
            Secure["Secure Flag"]
            SameSite["SameSite 策略"]
        end
    end

    StateParam --> OAuthFlow
    PKCE --> OAuthFlow
    HTTPS --> OAuthFlow
    
    AuthHeader --> AdapterAPI
    KVSecret --> AdapterAPI
    
    HttpOnly --> Session
    Secure --> Session
    SameSite --> Session
```

---

## 部署配置

### Kubernetes 配置

```mermaid
flowchart TB
    subgraph K8s["Kubernetes 部署"]
        direction TB
        
        ConfigMap["ConfigMap"]
        Secret["Secret"]
        Deployment["Deployment"]
        Service["Service"]
        Ingress["Ingress"]
    end

    ConfigMap -->|挂载| Deployment
    Secret -->|挂载| Deployment
    Deployment --> Service
    Service --> Ingress

    subgraph ConfigMapData["ConfigMap 数据"]
        CMClientID["AUTH_GOOGLE_CLIENT_ID"]
        CMClientSecret["AUTH_GOOGLE_CLIENT_SECRET"]
    end

    ConfigMapData --> ConfigMap
```

---

## 监控与埋点

### 事件追踪

```mermaid
flowchart LR
    subgraph Events["追踪事件"]
        Signup["user_signup"]
        Login["user_login"]
    end

    subgraph Metadata["事件属性"]
        UserId["user_id"]
        Country["country"]
        Device["device_type"]
        Browser["browser"]
        Wallet["wallet_name"]
        UTM["utm_source/medium/campaign"]
    end

    subgraph PostHog["PostHog 分析"]
        Analytics["用户行为分析"]
        Funnel["转化漏斗"]
    end

    Signup --> Metadata
    Login --> Metadata
    Metadata --> PostHog
```

---

## 故障排查

### 常见问题

```mermaid
flowchart TB
    subgraph Issues["常见问题"]
        direction TB
        
        I1["redirect_uri_mismatch"]
        I2["无法获取用户信息"]
        I3["会话未创建"]
        I4["CORS 错误"]
    end

    subgraph Solutions["解决方案"]
        S1["检查 Google Cloud Console 回调 URL 配置"]
        S2["确认 scope 配置和 Google+ API 启用"]
        S3["检查 NEXT_AUTH_SECRET 是否设置"]
        S4["配置 next.config.js headers"]
    end

    I1 --> S1
    I2 --> S2
    I3 --> S3
    I4 --> S4
```

---

## 相关资源

- [Google OAuth 文档](https://developers.google.com/identity/protocols/oauth2)
- [Google Cloud Console](https://console.cloud.google.com/)
- [NextAuth.js Google 提供商](https://next-auth.js.org/providers/google)
- [认证方式概览](../api/RESTful/auth-overview.md)

---

最后更新: 2026-03-17
