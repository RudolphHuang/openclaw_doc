# Apple V2 登录 API 文档

适用于移动端/桌面端等无法使用浏览器 OAuth 流程的场景。客户端先通过 Apple Sign In SDK 获取 authorization code，然后直接传递给服务端完成登录。

## 流程概述

```mermaid
sequenceDiagram
    participant Client as 客户端<br/>(iOS/macOS)
    participant Apple as Apple<br/>服务器
    participant Server as 服务端<br/>(NextAuth)

    Client->>Apple: 1. Apple Sign In SDK
    Apple-->>Client: 2. 返回 authorizationCode
    
    Client->>Server: 3. POST /callback/apple-v2<br/>(authorizationCode + csrfToken)
    Server->>Apple: 验证 authorizationCode
    Apple-->>Server: 返回 id_token + 用户信息
    Server-->>Client: 4. 返回 sessionToken
    
    Client->>Server: 5. 后续请求携带 sessionToken
```

## 1. 获取 CSRF Token

在调用登录接口前，需要先获取 CSRF token 用于防止 CSRF 攻击。

### 请求

```bash
curl --location 'https://chat-dev.ainft.com/api/auth/csrf?noCookie=1'
```

### 响应

```json
{
  "csrfToken": "45da5210042a71a301a9b375840c208520e09e563945a98d7179722335a7d674",
  "_cookies": [
    "__Secure-authjs.csrf-token=45da5210042a71a301a9b375840c208520e09e563945a98d7179722335a7d674%7C8f2618082f13bcd9eb6873f16ee065dea37e68afd1c66b7418a8206528883870; Path=/; HttpOnly; Secure; SameSite=Lax",
    "__Secure-authjs.callback-url=https%3A%2F%2Fchat-dev.ainft.com; Path=/; HttpOnly; Secure; SameSite=Lax"
  ]
}
```

### 字段说明

| 字段 | 类型 | 说明 |
|------|------|------|
| `csrfToken` | string | CSRF token，用于后续登录请求 |
| `_cookies` | array | 服务端设置的 cookie 列表（noCookie 模式下需要客户端自行管理） |

---

## 2. Apple V2 登录

使用 Apple authorization code 完成登录。

### 请求

```bash
curl --location 'https://chat-dev.ainft.com/api/auth/callback/apple-v2?noCookie=null' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'csrfToken=45da5210042a71a301a9b375840c208520e09e563945a98d7179722335a7d674' \
--data-urlencode 'authorizationCode=c8a5f1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0t1u2v3w4x5y6z7a8b9c0'
```

### 请求参数

#### URL 参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `noCookie` | string | 是 | 固定值 `null` 或 `1`，表示使用无 cookie 模式 |

#### Header

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `Content-Type` | string | 是 | 固定值 `application/x-www-form-urlencoded` |

#### Body (x-www-form-urlencoded)

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `csrfToken` | string | 是 | CSRF token（从 CSRF 接口获取） |
| `authorizationCode` | string | 是 | 从 Apple Sign In SDK 获取的 authorization code |

### 响应

```json
{
  "raw": "https://chat-dev.ainft.com",
  "_cookies": [
    "__Secure-authjs.callback-url=https%3A%2F%2Fchat-dev.ainft.com; Path=/; HttpOnly; Secure; SameSite=Lax",
    "__Secure-authjs.session-token=eyJhbGciOiJkaXIiLCJlbmMiOiJBMjU2Q0JDLUhTNTEyIiwia2lkIjoiZmRpajJBUnBic2FHNVVrRzBnNl9TMFRYS2s3LXNXV3lTdmlxV1J6Y2d6WVNzdXdTQk1XZ2Q2YXBFaEt0M2lrZjdrY3BFaUQ1Y1hpaHpaQVRHeDA5N1EifQ..SHkyRWMrDmRbhZYvXg6tTQ.GmuFQS-00iAbRVQzQ3KNYe32-q42VZ1wXLoFIQkv9OlkyS1b6c5EgW2tpllJ9uw57xGtaMhrLobY9xq3AU4duRJcYRRZS2v81quT76HazD_OZFaxkEitvpjMabJzXCHmxiuH-bihbDH3xWCv2VDk5ORFJ-gKlB96GJofi_QUvGZhMZ59_yqZx8uwC-b8Xifn7AJ6YMeJjLG2_SN0ChI_emRROI-XjZR74QCEs3aVwfz5wQFZbRm1aIkpSUZTtmZSpHADtkX7l6pkL0JWB-Hwu1tA7LLp5IPUsh0NwPRsFT-pvJYw1Qad4G7ptXjlItYSLDWH1RvlOklq1SsGn_FFC46sgdxKTvBO-j4jzQdZ6B_LnIThGs_mqq51lGI-AUIL6vzwqmZv0sfHe8HvQ33SgcmJZOge42aTh-qrYNJQAHANf12NgwNH2r5euTMZPHi9.veC7wYI3Ed1BCFiP7nwcvB5qTZ5TgWWWYuKwkUoQ-Og; Path=/; Expires=Sat, 28 Mar 2026 08:41:30 GMT; HttpOnly; Secure; SameSite=Lax"
  ]
}
```

### 响应字段说明

| 字段 | 类型 | 说明 |
|------|------|------|
| `raw` | string | 登录成功后的跳转 URL（通常是首页） |
| `_cookies` | array | 服务端设置的 cookie 列表，包含 `session-token` |

### 错误响应

#### CSRF 验证失败

```json
{
  "raw": "https://chat-dev.ainft.com/next-auth/signin?error=MissingCSRF",
  "_cookies": []
}
```

#### Authorization Code 无效

```json
{
  "raw": "https://chat-dev.ainft.com/next-auth/signin?error=CredentialsSignin&code=credentials",
  "_cookies": []
}
```

---

## 3. 使用 Session Token 访问受保护接口

登录成功后，从 `_cookies` 中提取 `session-token`，用于后续请求的身份验证。

### 提取 Session Token

从 cookie 字符串中提取：

```
__Secure-authjs.session-token=eyJhbGciOiJkaXIiLCJlbmMiOiJBMjU2Q0JDLUhTNTEyIiwia2lkIjoi...; Path=/; Expires=...
```

提取 `=` 和 `;` 之间的部分即为 session token。

### 调用 tRPC 接口示例

```bash
curl --location 'https://chat-dev.ainft.com/trpc/lambda/user.getUserState?batch=1&input=%7B%220%22%3A%7B%22json%22%3Anull%2C%22meta%22%3A%7B%22values%22%3A%5B%22undefined%22%5D%2C%22v%22%3A1%7D%7D%7D' \
--header 'X-No-Cookie: 1' \
--header 'X-Auth-Session-Token: eyJhbGciOiJkaXIiLCJlbmMiOiJBMjU2Q0JDLUhTNTEyIiwia2lkIjoi...'
```

### Header 说明

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `X-No-Cookie` | string | 是 | 固定值 `1`，表示使用无 cookie 模式 |
| `X-Auth-Session-Token` | string | 是 | 从登录响应中获取的 session token |

---

## 客户端完整示例

### iOS (Swift)

```swift
import AuthenticationServices

class AuthManager: NSObject, ASAuthorizationControllerDelegate {
    private var sessionToken: String?
    
    // 1. Apple 登录
    func signInWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    // ASAuthorizationControllerDelegate
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let authCodeData = credential.authorizationCode,
              let authCode = String(data: authCodeData, encoding: .utf8) else {
            print("Failed to get authorization code")
            return
        }
        
        // 2. 使用 authorization code 登录
        loginWithAppleV2(authorizationCode: authCode)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple Sign In failed: \(error)")
    }
    
    // 2. 服务端登录
    private func loginWithAppleV2(authorizationCode: String) {
        // 2.1 获取 CSRF token
        getCsrfToken { csrfToken in
            // 2.2 调用登录接口
            let url = URL(string: "https://chat-dev.ainft.com/api/auth/callback/apple-v2?noCookie=null")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            let body = "csrfToken=\(csrfToken)&authorizationCode=\(authorizationCode)"
            request.httpBody = body.data(using: .utf8)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let cookies = json["_cookies"] as? [String] else {
                    print("Login failed")
                    return
                }
                
                // 提取 session token
                self.sessionToken = self.extractSessionToken(from: cookies)
                print("Login success, session token saved")
            }.resume()
        }
    }
    
    // 3. 获取 CSRF token
    private func getCsrfToken(completion: @escaping (String) -> Void) {
        let url = URL(string: "https://chat-dev.ainft.com/api/auth/csrf?noCookie=1")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let csrfToken = json["csrfToken"] as? String else {
                return
            }
            completion(csrfToken)
        }.resume()
    }
    
    // 4. 提取 session token
    private func extractSessionToken(from cookies: [String]) -> String? {
        guard let cookie = cookies.first(where: { $0.contains("session-token") }),
              let range = cookie.range(of: "session-token=") else { return nil }
        
        let tokenStart = cookie.index(range.upperBound, offsetBy: 0)
        let tokenEnd = cookie.firstIndex(of: ";") ?? cookie.endIndex
        return String(cookie[tokenStart..<tokenEnd])
    }
    
    // 5. 调用 API
    func fetchUserState() {
        guard let sessionToken = sessionToken else {
            print("No session token")
            return
        }
        
        let url = URL(string: "https://chat-dev.ainft.com/trpc/lambda/user.getUserState?batch=1&input=%7B%220%22%3A%7B%22json%22%3Anull%7D%7D")!
        var request = URLRequest(url: url)
        request.setValue("1", forHTTPHeaderField: "X-No-Cookie")
        request.setValue(sessionToken, forHTTPHeaderField: "X-Auth-Session-Token")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // 处理响应
            if let data = data {
                print("Response: \(String(data: data, encoding: .utf8) ?? "")")
            }
        }.resume()
    }
}

// ASAuthorizationControllerPresentationContextProviding
extension AuthManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 返回当前 window
        return UIApplication.shared.windows.first { $0.isKeyWindow }!
    }
}
```

### Android (Kotlin)

```kotlin
class AuthManager(private val context: Context) {
    private var sessionToken: String? = null
    private val client = OkHttpClient()
    private val gson = Gson()
    
    // 1. Apple 登录 (使用 Chrome Custom Tabs 或 WebView)
    fun signInWithApple(activity: Activity) {
        // Android 需要使用 Web 端的 Apple Sign In
        // 或者使用第三方库如 'com.willowtreeapps:signinwithapplebutton'
        val appleAuthUrl = buildAppleAuthUrl()
        
        val intent = CustomTabsIntent.Builder().build()
        intent.launchUrl(activity, Uri.parse(appleAuthUrl))
    }
    
    // 构建 Apple OAuth URL
    private fun buildAppleAuthUrl(): String {
        val clientId = "your.service.id"
        val redirectUri = "https://chat-dev.ainft.com/api/auth/callback/apple"
        val state = UUID.randomUUID().toString()
        
        return "https://appleid.apple.com/auth/authorize" +
               "?client_id=$clientId" +
               "&redirect_uri=$redirectUri" +
               "&response_type=code" +
               "&scope=name%20email" +
               "&state=$state"
    }
    
    // 2. 服务端登录
    fun loginWithAppleV2(authorizationCode: String) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                // 2.1 获取 CSRF token
                val csrfToken = getCsrfToken()
                
                // 2.2 调用登录接口
                val url = "https://chat-dev.ainft.com/api/auth/callback/apple-v2?noCookie=null"
                val body = "csrfToken=$csrfToken&authorizationCode=$authorizationCode"
                    .toRequestBody("application/x-www-form-urlencoded".toMediaType())
                
                val request = Request.Builder()
                    .url(url)
                    .post(body)
                    .build()
                
                val response = client.newCall(request).execute()
                val json = gson.fromJson(response.body?.string(), JsonObject::class.java)
                
                // 提取 session token
                val cookies = json.getAsJsonArray("_cookies")
                sessionToken = extractSessionToken(cookies)
                
                withContext(Dispatchers.Main) {
                    Log.i("Auth", "Login success")
                }
            } catch (e: Exception) {
                Log.e("Auth", "Login failed", e)
            }
        }
    }
    
    // 3. 获取 CSRF token
    private suspend fun getCsrfToken(): String = suspendCancellableCoroutine { continuation ->
        val url = "https://chat-dev.ainft.com/api/auth/csrf?noCookie=1"
        val request = Request.Builder().url(url).build()
        
        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                continuation.resumeWithException(e)
            }
            
            override fun onResponse(call: Call, response: Response) {
                val json = gson.fromJson(response.body?.string(), JsonObject::class.java)
                val csrfToken = json.get("csrfToken").asString
                continuation.resume(csrfToken)
            }
        })
    }
    
    // 4. 提取 session token
    private fun extractSessionToken(cookies: JsonArray): String? {
        val cookie = cookies.firstOrNull { it.asString.contains("session-token") }?.asString ?: return null
        val regex = "session-token=([^;]+)".toRegex()
        return regex.find(cookie)?.groupValues?.get(1)
    }
    
    // 5. 调用 API
    fun fetchUserState(callback: (UserState?) -> Unit) {
        val token = sessionToken ?: return callback(null)
        
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val url = "https://chat-dev.ainft.com/trpc/lambda/user.getUserState?batch=1&input=%7B%220%22%3A%7B%22json%22%3Anull%7D%7D"
                val request = Request.Builder()
                    .url(url)
                    .header("X-No-Cookie", "1")
                    .header("X-Auth-Session-Token", token)
                    .build()
                
                val response = client.newCall(request).execute()
                val userState = gson.fromJson(response.body?.string(), UserState::class.java)
                callback(userState)
            } catch (e: Exception) {
                Log.e("Auth", "Fetch user state failed", e)
                callback(null)
            }
        }
    }
}
```

---

## Apple Token 接口

服务端使用 Apple 的 token 接口验证 authorization code 并获取用户信息。

### 请求示例

```bash
curl --location 'https://appleid.apple.com/auth/token' \
--form 'client_id="com.ainft.app"' \
--form 'client_secret="？？？"' \
--form 'code="c43bab889fd63488abc5e7e607ddf3566.0.mrxuv.mDSfuKelQNU_LqEecDRRHw"' \
--form 'grant_type="authorization_code"'
```

### 请求参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `client_id` | string | 是 | Apple Services ID (如 `com.ainft.app`) |
| `client_secret` | string | 是 | 从密钥文件读取的 JWT 令牌，使用 `@/path/to/file` 语法 |
| `code` | string | 是 | 从 Apple Sign In SDK 获取的 authorization code |
| `grant_type` | string | 是 | 固定值 `authorization_code` |

### client_secret 密钥文件

`client_secret` 是一个 JWT (JSON Web Token)，需要使用以下方式生成：

### 响应示例

```json
{
  "access_token": "eyJraWQiOiJlWGF1bm1MIiwiYWxnIjoiUlMyNTYifQ...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "refresh_token": "eyJraWQiOiJlWGF1bm1MIiwiYWxnIjoiUlMyNTYifQ...",
  "id_token": "eyJraWQiOiJlWGF1bm1MIiwiYWxnIjoiUlMyNTYifQ..."
}
```

### 响应字段说明

| 字段 | 类型 | 说明 |
|------|------|------|
| `access_token` | string | Apple 访问令牌 |
| `token_type` | string | 令牌类型，固定为 `Bearer` |
| `expires_in` | number | 访问令牌有效期（秒） |
| `refresh_token` | string | 刷新令牌（仅首次授权时返回） |
| `id_token` | string | JWT 格式的用户身份信息，包含 `sub`（Apple User ID） |

### 错误响应

```json
{
  "error": "invalid_grant",
  "error_description": "The code has already been used or has expired"
}
```

---

## 环境变量配置

服务端需要配置以下环境变量：

```bash
# Apple V2 Sign In (Server-side validation)
AUTH_APPLE_V2_ID=com.example.app          # Apple Services ID
AUTH_APPLE_V2_TEAM_ID=YOUR_TEAM_ID        # Apple Team ID (10字符)
AUTH_APPLE_V2_KEY_ID=YOUR_KEY_ID          # Private Key ID (10字符)
AUTH_APPLE_V2_PRIVATE_KEY=-----BEGIN EC PRIVATE KEY-----YOUR_PRIVATE_KEY_CONTENT-----END EC PRIVATE KEY-----
```

---

## 注意事项

1. **Authorization Code 一次性使用** - Apple 的 authorization code 只能使用一次，用过后会失效
2. **CSRF Token 一次性使用** - 每个 CSRF token 只能使用一次，登录失败后需要重新获取
3. **Session Token 存储** - 需要安全存储（iOS Keychain / Android Keystore）
4. **HTTPS 必需** - 生产环境必须使用 HTTPS 传输 token
5. **Android 限制** - Android 原生不支持 Apple Sign In，需要使用 Web 流程或第三方库
6. **Private Key 格式** - 需要从 Apple Developer 下载 `.p8` 文件，内容格式为 PEM 格式
