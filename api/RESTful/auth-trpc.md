# tRPC Lambda 鉴权与 401（以 user.getUserState 为例）

## 概述

`/trpc/lambda/user.getUserState` 等需要登录的接口在**未携带 cookie**（且无其他认证方式）时会返回 **401 UNAUTHORIZED**。本文说明鉴权链路与 401 产生位置。

示例错误响应：

```json
[
  {
    "error": {
      "json": {
        "message": "UNAUTHORIZED",
        "code": -32001,
        "data": {
          "code": "UNAUTHORIZED",
          "httpStatus": 401,
          "path": "user.getUserState"
        }
      }
    }
  }
]
```

---

## 1. 接口与 Procedure 链

- **路径**：`/trpc/lambda/user.getUserState`
- **实现**：`src/server/routers/lambda/user.ts` 中的 `getUserState`，使用 **`userProcedure`**。
- **`userProcedure`**：`authedProcedure.use(serverDatabase).use(...)`，即先鉴权再挂数据库与业务 context。
- **`authedProcedure`**（`src/libs/trpc/lambda/index.ts`）：  
  `trpc.procedure.use(oidcAuth).use(userAuth)`  
  即：先经过 **oidcAuth**，再经过 **userAuth**。

---

## 2. 401 的抛出位置（限制发生处）

401 在 **`userAuth`** 中间件中抛出：

- **文件**：`src/libs/trpc/middleware/userAuth.ts`
- **逻辑**：当 `ctx.userId` 为空时，`throw new TRPCError({ code: 'UNAUTHORIZED' })`（约第 19–25 行）。

桌面端会跳过该鉴权（使用 `DESKTOP_USER_ID`）；非桌面端且无 `userId` 即 401。

---

## 3. ctx.userId 的来源（为何没 cookie 会 401）

`ctx` 由 **lambda 的 createContext** 提供，实现在 **`src/libs/trpc/lambda/context.ts`** 的 `createLambdaContext`。  
其中 `userId` 的解析顺序大致为：

| 顺序 | 方式           | 说明 |
|------|----------------|------|
| 1    | OIDC           | 若启用 OIDC，从 `Oidc-Auth` 等 header 的 JWT 解析出用户 |
| 2    | 系统 API Key   | `Authorization: Bearer <api-key>` 校验通过后得到 userId |
| 3    | Clerk          | `enableClerk` 时，`clerkAuth.getAuthFromRequest(request)`，**依赖 cookie/session** |
| 4    | NextAuth       | `enableNextAuth` 时，`NextAuth.auth()` 取 session，**依赖 cookie** |

若以上都未通过（例如未带 cookie、也未带 OIDC/API Key），则 **`userId` 为 `undefined`**，请求进入 **userAuth** 时被判定未登录并返回 401。

---

## 4. 相关代码位置速查

| 内容           | 路径 |
|----------------|------|
| getUserState 实现 | `src/server/routers/lambda/user.ts` |
| userProcedure / authedProcedure | `src/server/routers/lambda/user.ts`、`src/libs/trpc/lambda/index.ts` |
| 401 抛出（userAuth） | `src/libs/trpc/middleware/userAuth.ts` |
| Context 与 userId 解析 | `src/libs/trpc/lambda/context.ts` |
| oidcAuth 中间件 | `src/libs/trpc/lambda/middleware/oidcAuth.ts` |

---

## 5. 若希望未登录也可访问 getUserState

如需在未登录时也允许调用 `getUserState`（例如返回「未初始化」状态），可以：

- 为 `getUserState` 使用**不经过 userAuth** 的 procedure（例如 `publicProcedure`），并在 handler 内根据 `ctx.userId` 是否存在分支处理；或  
- 在路由/中间件层对 `user.getUserState` 做例外放行（不推荐在通用 userAuth 里按 path 写死例外）。

建议优先采用单独的 public procedure + 内部判断 `userId` 的方式，以保持鉴权语义清晰。
