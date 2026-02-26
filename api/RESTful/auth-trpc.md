# tRPC 接口无 Cookie 认证方案

本文档说明如何在安卓等无法使用 Cookie 的客户端环境中调用 tRPC 接口。

## 问题背景

LobeChat 的 tRPC 接口默认通过 `NextAuth.auth()` 从请求 Cookie 中获取 session 信息。当安卓客户端无法使用 Cookie 时，需要修改代码以支持从 Header 中获取认证信息。

## 当前代码分析

### 1. tRPC 路由入口

**文件**: `src/app/(backend)/trpc/lambda/[trpc]/route.ts`

```typescript
const handler = (req: NextRequest) =>
  fetchRequestHandler({
    createContext: () => createLambdaContext(req),  // 创建上下文
    endpoint: '/trpc/lambda',
    router: lambdaRouter,
    // ...
  });
```

### 2. 上下文创建逻辑

**文件**: `src/libs/trpc/lambda/context.ts`

当前 `createLambdaContext` 函数通过 `NextAuth.auth()` 获取 session：

```typescript
if (enableNextAuth) {
  try {
    const { default: NextAuth } = await import('@/libs/next-auth');
    const session = await NextAuth.auth();  // 从 Cookie 读取 session
    if (session && session?.user?.id) {
      userId = session.user.id;
    }
    return createContextInner({
      nextAuth: auth,
      ...commonContext,
      userId,
    });
  } catch (e) {
    // ...
  }
}
```

**问题**: `NextAuth.auth()` 默认从请求 Cookie 中读取 session token，无法直接从 Header 读取。

## 解决方案

### 方案一：修改上下文创建逻辑（推荐）

修改 `src/libs/trpc/lambda/context.ts`，在无 Cookie 模式下从 Header 读取 session token。

#### 代码修改

```typescript
// src/libs/trpc/lambda/context.ts

// 新增：从 Header 获取 NextAuth session token
const getSessionTokenFromHeader = (request: NextRequest): string | null => {
  // 支持多种 header 名称
  const token = 
    request.headers.get('X-Auth-Session-Token') ||
    request.headers.get('x-auth-session-token') ||
    request.headers.get('Authorization')?.replace('Bearer ', '') ||
    null;
  return token;
};

// 新增：验证 session token 并获取用户信息
const validateSessionToken = async (token: string): Promise<{ userId: string; user?: User } | null> => {
  try {
    // 使用 NextAuth 的 JWT 验证逻辑
    const { default: NextAuth } = await import('@/libs/next-auth');
    
    // 方法 1: 如果 NextAuth 暴露了解码方法
    // const decoded = await NextAuth.decodeToken(token);
    
    // 方法 2: 手动验证 JWT
    const jwt = await import('jsonwebtoken');
    const { NEXT_AUTH_SECRET } = getAuthConfig();
    const decoded = jwt.verify(token, NEXT_AUTH_SECRET!) as any;
    
    if (decoded?.userId || decoded?.sub) {
      return {
        userId: decoded.userId || decoded.sub,
        user: decoded.user,
      };
    }
    return null;
  } catch (error) {
    log('Session token validation error:', error);
    return null;
  }
};

// 修改 createLambdaContext 函数
export const createLambdaContext = async (request: NextRequest): Promise<LambdaContext> => {
  // ... 原有代码 ...

  if (enableNextAuth) {
    log('Attempting NextAuth authentication');
    try {
      const { default: NextAuth } = await import('@/libs/next-auth');

      // 优先尝试从 Cookie 获取 session（原有逻辑）
      let session = await NextAuth.auth();
      
      // 如果 Cookie 中没有 session，尝试从 Header 获取
      if (!session?.user?.id) {
        const sessionToken = getSessionTokenFromHeader(request);
        if (sessionToken) {
          log('Found session token in header, validating...');
          const validated = await validateSessionToken(sessionToken);
          if (validated) {
            userId = validated.userId;
            auth = validated.user || { id: validated.userId };
            log('Header session validation successful, userId: %s', userId);
          }
        }
      } else {
        // Cookie 中有 session，使用原有逻辑
        auth = session.user;
        userId = session.user.id;
        log('NextAuth authentication successful from cookie, userId: %s', userId);
      }
      
      return createContextInner({
        nextAuth: auth,
        ...commonContext,
        requestUrl: request.url,
        userId,
      });
    } catch (e) {
      log('NextAuth authentication error: %O', e);
      console.error('next auth err', e);
    }
  }

  // ... 后续代码 ...
};
```

### 方案二：使用中间件转换 Header 到 Cookie

在 tRPC 路由入口处添加中间件，将 Header 中的 token 转换为 Cookie。

#### 代码修改

**文件**: `src/app/(backend)/trpc/lambda/[trpc]/route.ts`

```typescript
import { fetchRequestHandler } from '@trpc/server/adapters/fetch';
import type { NextRequest } from 'next/server';

import { pino } from '@/libs/logger';
import { createLambdaContext } from '@/libs/trpc/lambda/context';
import { lambdaRouter } from '@/server/routers/lambda';

// 新增：将 Header 中的 session token 转换为 Cookie
const injectCookieFromHeader = (req: NextRequest): NextRequest => {
  const sessionToken = req.headers.get('X-Auth-Session-Token');
  if (!sessionToken) return req;

  // 克隆请求并添加 Cookie
  const newHeaders = new Headers(req.headers);
  const existingCookie = newHeaders.get('cookie') || '';
  const cookieValue = `authjs.session-token=${sessionToken}; Path=/; HttpOnly`;
  newHeaders.set('cookie', existingCookie ? `${existingCookie}; ${cookieValue}` : cookieValue);
  
  // 创建新请求（NextRequest 是只读的）
  const newReq = new Request(req.url, {
    method: req.method,
    headers: newHeaders,
    body: req.body,
  }) as NextRequest;
  
  return newReq;
};

const handler = (req: NextRequest) => {
  // 注入 Cookie
  const modifiedReq = injectCookieFromHeader(req);
  
  return fetchRequestHandler({
    createContext: () => createLambdaContext(modifiedReq),
    endpoint: '/trpc/lambda',
    onError: ({ error, path, type }) => {
      pino.info(`Error in tRPC handler (lambda) on path: ${path}, type: ${type}`);
      console.error(error);
    },
    req: modifiedReq,
    responseMeta({ ctx }) {
      const headers = ctx?.resHeaders;
      return { headers };
    },
    router: lambdaRouter,
  });
};

export { handler as GET, handler as POST };
```

### 方案三：使用 NextAuth 的自定义 Cookie 名称配置

修改 `src/libs/next-auth/edge.ts` 和 `src/libs/next-auth/auth.config.ts`，添加自定义 cookie 名称支持。

#### 代码修改

**文件**: `src/libs/next-auth/edge.ts`

```typescript
const edgeAuthConfig: NextAuthConfig = {
  // ... 原有配置 ...
  
  // 新增：自定义 cookies 配置
  cookies: {
    sessionToken: {
      name: `__Host-authjs.session-token`,
      options: {
        httpOnly: true,
        sameSite: 'lax',
        path: '/',
        secure: true,
      },
    },
    callbackUrl: {
      name: `__Secure-authjs.callback-url`,
      options: {
        httpOnly: true,
        sameSite: 'lax',
        path: '/',
        secure: true,
      },
    },
    csrfToken: {
      name: `__Host-authjs.csrf-token`,
      options: {
        httpOnly: true,
        sameSite: 'lax',
        path: '/',
        secure: true,
      },
    },
  },
  
  // ... 后续配置 ...
};
```

## 安卓客户端调用示例

### 修改后的调用方式

```kotlin
class TrpcClient(private val baseUrl: String) {
    private var sessionToken: String? = null
    private var csrfToken: String? = null
    
    // 存储 token 到 EncryptedSharedPreferences
    fun saveTokens(session: String, csrf: String) {
        sessionToken = session
        csrfToken = csrf
        // 持久化存储...
    }
    
    // 调用 tRPC 接口
    suspend fun <T> call(
        procedure: String,
        params: Map<String, Any>,
        requireAuth: Boolean = true
    ): T {
        val url = "$baseUrl/trpc/lambda/$procedure"
        
        val headers = mutableMapOf(
            "Content-Type" to "application/json"
        )
        
        // 添加无 Cookie 模式标记
        headers["X-No-Cookie"] = "1"
        
        // 添加认证 Header
        if (requireAuth && sessionToken != null) {
            headers["X-Auth-Session-Token"] = sessionToken!!
        }
        
        // 添加 CSRF Token（写操作需要）
        if (csrfToken != null) {
            headers["X-Auth-CSRF-Token"] = csrfToken!!
        }
        
        val request = Request.Builder()
            .url(url)
            .headers(headers.toHeaders())
            .post(
                json.encodeToString(
                    mapOf(
                        "json" to params,
                        "meta" to mapOf(
                            "values" to emptyMap<String, Any>()
                        )
                    )
                ).toRequestBody()
            )
            .build()
        
        val response = httpClient.newCall(request).execute()
        
        // 处理响应...
        return parseResponse(response)
    }
}

// 使用示例
suspend fun getSessions(client: TrpcClient) {
    val result = client.call<Map<String, Any>>(
        procedure = "session.getSessions",
        params = mapOf(
            "current" to 1,
            "pageSize" to 20
        ),
        requireAuth = true
    )
    println("Sessions: $result")
}
```

## 完整修改代码

### 1. 修改 `src/libs/trpc/lambda/context.ts`

```typescript
import { ClientSecretPayload } from '@lobechat/types';
import { validateApiKeyFormat } from '@lobechat/utils/apiKey';
import { getClientIP } from '@lobechat/utils/clientIP';
import { extractBearerToken } from '@lobechat/utils/server';
import { parse } from 'cookie';
import debug from 'debug';
import * as jose from 'jose';
import { User } from 'next-auth';
import { NextRequest } from 'next/server';

import {
  LOBE_CHAT_AUTH_HEADER,
  LOBE_CHAT_OIDC_AUTH_HEADER,
  enableClerk,
  enableNextAuth,
} from '@/const/auth';
import { getAuthConfig } from '@/envs/auth';
import { oidcEnv } from '@/envs/oidc';
import { ClerkAuth, IClerkAuth } from '@/libs/clerk-auth';
import { validateOIDCJWT } from '@/libs/oidc-provider/jwt';

const log = debug('lobe-trpc:lambda:context');

// ============ 新增：无 Cookie 模式支持 ============

/**
 * 从请求 Header 中获取 NextAuth session token
 */
const getSessionTokenFromHeader = (request: NextRequest): string | null => {
  // 支持多种 header 名称（大小写不敏感）
  const token =
    request.headers.get('X-Auth-Session-Token') ||
    request.headers.get('x-auth-session-token') ||
    request.headers.get('X-Auth-Token') ||
    request.headers.get('authorization')?.replace(/^Bearer\s+/i, '') ||
    null;
  return token;
};

/**
 * 验证 session token 并解码
 * 使用 jose 库验证 JWT
 */
const validateAndDecodeSessionToken = async (token: string): Promise<{ userId: string; user?: User } | null> => {
  try {
    const { NEXT_AUTH_SECRET } = getAuthConfig();
    if (!NEXT_AUTH_SECRET) {
      log('NEXT_AUTH_SECRET not configured');
      return null;
    }

    // 使用 jose 验证 JWT
    const secret = new TextEncoder().encode(NEXT_AUTH_SECRET);
    const { payload } = await jose.jwtVerify(token, secret);

    // NextAuth JWT 格式: { userId: string, sub: string, ... }
    const userId = (payload.userId as string) || (payload.sub as string);
    
    if (userId) {
      log('Session token validated, userId: %s', userId);
      return {
        userId,
        user: {
          id: userId,
          email: payload.email as string,
          name: payload.name as string,
          image: payload.picture as string,
        } as User,
      };
    }
    return null;
  } catch (error) {
    log('Session token validation error: %O', error);
    return null;
  }
};

/**
 * 检查是否为无 Cookie 模式请求
 */
const isNoCookieMode = (request: NextRequest): boolean => {
  return (
    request.headers.get('X-No-Cookie') === '1' ||
    new URL(request.url).searchParams.has('noCookie')
  );
};

// ============ 原有代码 ============

export interface OIDCAuth {
  [key: string]: any;
  payload: any;
  sub: string;
}

export interface AuthContext {
  authorizationHeader?: string | null;
  clerkAuth?: IClerkAuth;
  clientIP?: string;
  jwtPayload?: ClientSecretPayload | null;
  marketAccessToken?: string;
  nextAuth?: User;
  oidcAuth?: OIDCAuth | null;
  referer?: string;
  requestUrl?: string;
  resHeaders?: Headers;
  userAgent?: string;
  userId?: string | null;
}

export const createContextInner = async (params?: {
  authorizationHeader?: string | null;
  clerkAuth?: IClerkAuth;
  clientIP?: string;
  jwtPayload?: ClientSecretPayload | null;
  marketAccessToken?: string;
  nextAuth?: User;
  oidcAuth?: OIDCAuth | null;
  referer?: string;
  requestUrl?: string;
  userAgent?: string;
  userId?: string | null;
}): Promise<AuthContext> => {
  log('createContextInner called with params: %O', params);
  const responseHeaders = new Headers();

  return {
    authorizationHeader: params?.authorizationHeader,
    clerkAuth: params?.clerkAuth,
    clientIP: params?.clientIP,
    jwtPayload: params?.jwtPayload,
    marketAccessToken: params?.marketAccessToken,
    nextAuth: params?.nextAuth,
    oidcAuth: params?.oidcAuth,
    referer: params?.referer,
    requestUrl: params?.requestUrl,
    resHeaders: responseHeaders,
    userAgent: params?.userAgent,
    userId: params?.userId,
  };
};

export type LambdaContext = Awaited<ReturnType<typeof createContextInner>>;

export const createLambdaContext = async (request: NextRequest): Promise<LambdaContext> => {
  const isDebugApi = request.headers.get('lobe-auth-dev-backend-api') === '1';
  const isMockUser = process.env.ENABLE_MOCK_DEV_USER === '1';

  if (process.env.NODE_ENV === 'development' && (isDebugApi || isMockUser)) {
    return { userId: process.env.MOCK_DEV_USER_ID };
  }

  log('createLambdaContext called for request');
  
  // 检测无 Cookie 模式
  const noCookieMode = isNoCookieMode(request);
  if (noCookieMode) {
    log('No-cookie mode detected');
  }

  const authorization = request.headers.get(LOBE_CHAT_AUTH_HEADER);
  const userAgent = request.headers.get('user-agent') || undefined;
  const referer = request.headers.get('referer') || request.headers.get('Referer') || undefined;
  const clientIP = getClientIP(request.headers);

  const cookieHeader = request.headers.get('cookie');
  const cookies = cookieHeader ? parse(cookieHeader) : {};
  const marketAccessToken = cookies['mp_token'];

  log('marketAccessToken from cookie:', marketAccessToken ? '[HIDDEN]' : 'undefined');
  const commonContext = {
    authorizationHeader: authorization,
    clientIP,
    marketAccessToken,
    referer,
    userAgent,
  };
  log('LobeChat Authorization header: %s', authorization ? 'exists' : 'not found');

  let userId;
  let auth;
  let oidcAuth = null;

  // OIDC 认证（优先）
  if (oidcEnv.ENABLE_OIDC) {
    log('OIDC enabled, attempting OIDC authentication');
    const standardAuthorization = request.headers.get('Authorization');
    const oidcAuthToken = request.headers.get(LOBE_CHAT_OIDC_AUTH_HEADER);

    try {
      if (oidcAuthToken) {
        const tokenInfo = await validateOIDCJWT(oidcAuthToken);
        oidcAuth = {
          payload: tokenInfo.tokenData,
          ...tokenInfo.tokenData,
          sub: tokenInfo.userId,
        };
        userId = tokenInfo.userId;
        log('OIDC authentication successful, userId: %s', userId);
        return createContextInner({
          oidcAuth,
          ...commonContext,
          requestUrl: request.url,
          userId,
        });
      }
    } catch (error) {
      if (oidcAuthToken) {
        log('OIDC authentication failed, error: %O', error);
      }
    }
  }

  // 系统 API Key 认证
  const standardAuth = request.headers.get('Authorization');
  const bearerToken = extractBearerToken(standardAuth);

  if (bearerToken && validateApiKeyFormat(bearerToken)) {
    try {
      const { validateSystemApiKey } = await import('@/app/(backend)/middleware/auth/systemApiKey');
      const apiKeyUserId = await validateSystemApiKey(bearerToken);
      if (apiKeyUserId) {
        log('System API key authentication successful, userId: %s', apiKeyUserId);
        return createContextInner({
          ...commonContext,
          jwtPayload: { useSystemApiKey: true, userId: apiKeyUserId },
          requestUrl: request.url,
          userId: apiKeyUserId,
        });
      }
    } catch (error) {
      log('System API key authentication error: %O', error);
    }
  }

  // Clerk 认证
  if (enableClerk) {
    log('Attempting Clerk authentication');
    const clerkAuth = new ClerkAuth();
    const result = clerkAuth.getAuthFromRequest(request);
    auth = result.clerkAuth;
    userId = result.userId;
    log('Clerk authentication result, userId: %s', userId || 'not authenticated');
    return createContextInner({
      clerkAuth: auth,
      ...commonContext,
      requestUrl: request.url,
      userId,
    });
  }

  // NextAuth 认证（修改支持无 Cookie 模式）
  if (enableNextAuth) {
    log('Attempting NextAuth authentication');
    try {
      const { default: NextAuth } = await import('@/libs/next-auth');

      // 方法 1: 尝试从 Cookie 获取 session（原有逻辑）
      let session = await NextAuth.auth();
      
      // 方法 2: 如果 Cookie 没有 session 且是无 Cookie 模式，从 Header 获取
      if ((!session?.user?.id || noCookieMode) && !userId) {
        const sessionToken = getSessionTokenFromHeader(request);
        if (sessionToken) {
          log('Found session token in header, validating...');
          const validated = await validateAndDecodeSessionToken(sessionToken);
          if (validated) {
            userId = validated.userId;
            auth = validated.user;
            log('Header session validation successful, userId: %s', userId);
          } else {
            log('Header session validation failed');
          }
        }
      } else if (session?.user?.id) {
        // 使用 Cookie 中的 session
        auth = session.user;
        userId = session.user.id;
        log('NextAuth authentication successful from cookie, userId: %s', userId);
      }
      
      return createContextInner({
        nextAuth: auth,
        ...commonContext,
        requestUrl: request.url,
        userId,
      });
    } catch (e) {
      log('NextAuth authentication error: %O', e);
      console.error('next auth err', e);
    }
  }

  log('All authentication methods attempted, returning final context, userId: %s', userId || 'not authenticated');
  return createContextInner({ ...commonContext, requestUrl: request.url, userId });
};
```

### 2. 安装依赖

```bash
npm install jose
# 或
yarn add jose
# 或
pnpm add jose
```

## 测试验证

### 1. 使用 curl 测试

```bash
# 1. 先登录获取 session token
curl -X POST "https://your-domain.com/api/auth/callback/tronlink?noCookie" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "X-No-Cookie: 1" \
  -d "message=..." \
  -d "signature=..." \
  -d "version=2" \
  -d "csrfToken=..." \
  -d "callbackUrl=/"

# 2. 从响应中提取 session-token

# 3. 调用 tRPC 接口
curl -X POST "https://your-domain.com/trpc/lambda/session.getSessions" \
  -H "Content-Type: application/json" \
  -H "X-Auth-Session-Token: YOUR_SESSION_TOKEN" \
  -H "X-No-Cookie: 1" \
  -d '{
    "json": {
      "current": 1,
      "pageSize": 20
    }
  }'
```

### 2. 安卓端测试

```kotlin
@Test
fun testTrpcWithHeaderAuth() = runBlocking {
    // 1. 登录获取 token
    val loginResult = authService.loginWithTronLink(
        message = siweMessage,
        signature = signature
    )
    val sessionToken = loginResult.sessionToken
    
    // 2. 使用 token 调用 tRPC
    val trpcClient = TrpcClient("https://your-domain.com")
    trpcClient.saveTokens(sessionToken, "")
    
    val sessions = trpcClient.call<Map<String, Any>>(
        procedure = "session.getSessions",
        params = mapOf("current" to 1, "pageSize" to 20)
    )
    
    assertNotNull(sessions)
    println("Sessions: $sessions")
}
```

## 注意事项

1. **安全性**
   - 生产环境必须使用 HTTPS
   - Session token 需要安全存储（Android KeyStore / iOS Keychain）
   - 避免在日志中打印 token

2. **Token 过期**
   - 默认 30 天过期
   - 需要处理 401 错误并重新登录

3. **兼容性**
   - 修改后的代码保持向后兼容（Cookie 模式仍然有效）
   - 无 Cookie 模式需要显式添加 `X-No-Cookie: 1` header

4. **性能**
   - JWT 验证是同步的，性能开销小
   - 不需要额外的数据库查询

## 相关文件

- `src/libs/trpc/lambda/context.ts` - tRPC Lambda 上下文
- `src/libs/trpc/edge/context.ts` - tRPC Edge 上下文（类似修改）
- `src/app/(backend)/trpc/lambda/[trpc]/route.ts` - tRPC 路由入口
- `src/libs/next-auth/edge.ts` - NextAuth Edge 配置
- `src/libs/next-auth/auth.config.ts` - NextAuth Node 配置
