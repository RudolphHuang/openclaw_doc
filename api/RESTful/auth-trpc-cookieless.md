# tRPC 无 Cookie 认证方案

## 概述

在无 Cookie 环境下（如安卓 WebView 或特定原生应用环境）调用 tRPC 接口时，需要通过特定的 Header 字段传递认证信息。

## 适用场景

- 安卓 WebView 中 Cookie 被禁用或受限
- 原生应用直接调用 tRPC API
- 需要手动管理 Session 的客户端

## 认证 Header

### 必需 Header

| Header 字段 | 说明 | 使用场景 |
|------------|------|----------|
| `X-No-Cookie` | 固定值 `1`，告知服务端不使用 Cookie | 所有无 Cookie 请求 |
| `X-Auth-Session-Token` | Session Token | 所有需要认证的请求 |


## 请求格式

### tRPC Batch 请求

tRPC 使用 batch 模式进行请求，URL 格式如下：

```
/trpc/lambda/{procedure}?batch=1&input={encoded_input}
```

其中 `input` 参数是经过 URL 编码的 JSON 对象：

```typescript
// 无入参时的 input 格式
{
  "0": {
    "json": null,
    "meta": {
      "values": ["undefined"],
      "v": 1
    }
  }
}
```

URL 编码后：
```
%7B%220%22%3A%7B%22json%22%3Anull%2C%22meta%22%3A%7B%22values%22%3A%5B%22undefined%22%5D%2C%22v%22%3A1%7D%7D%7D
```

## 示例请求

### 获取用户状态 (user.getUserState)

```bash
curl --location 'https://chat-dev.ainft.com/trpc/lambda/user.getUserState?batch=1&input=%7B%220%22%3A%7B%22json%22%3Anull%2C%22meta%22%3A%7B%22values%22%3A%5B%22undefined%22%5D%2C%22v%22%3A1%7D%7D%7D' \
--header 'accept: */*' \
--header 'X-No-Cookie: 1' \
--header 'X-Auth-Session-Token: eyJhbGciOiJkaXIiLCJlbmMiOiJBMjU2Q0JDLUhTNTEyIiwia2lkIjoiZmRpajJBUnBic2FHNVVrRzBnNl9TMFRYS2s3LXNXV3lTdmlxV1J6Y2d6WVNzdXdTQk1XZ2Q2YXBFaEt0M2lrZjdrY3BFaUQ1Y1hpaHpaQVRHeDA5N1EifQ..wmKOzgtDasjm9HNn2YSzsA.lHywl2dppU_j6PQM81WSIwM1IKBGu8G7ViCrOuhvz1QEUBrRepdWG91GnBQXLhr65pS0NQ7qh4lx4YCE6LqMXbmrLSoVFyyyDv3sVqchstfVtH0EIbWLsjknQ3P_gmbUZCMHWMoa4_F-4S39E9-X3fEhNDHkova8AHxkBammYiH7WPojVemrmaRZ7R25_82IGZUyaHxvg46Ehncqz8QIG-xBC63Ij_Kw7ooQgjKyNM7xMwhdQDnPHEh55sb1_sWxOMZBs1noumJCZZO3nmA0Z582BW2nDwcVRWzvLio6lTaMtxhU8X71tZi6-4VadLVGpo1phKzDb1eCn8blFqxtBf3T98mvYbYo64oDdXHRRnimdUhJAJK0HtLzNaD95AbP88udq6IguvaA_zCmAZkj0vNbVN8_j3gjjWechyCRDjM.nFzCDBSeVfhesP7wfScs5-PfTFIGGagqfDLAISJIMt0' \
```

### 响应示例

```json
[
  {
    "result": {
      "data": {
        "json": {
          "avatar": "https://lh3.googleusercontent.com/a-/ALV-UjVZgJcNSyEZ8tPYH5nZ-9HEFK4wdBmvRyNw1mhGg7g1nc2wiA=s96-c",
          "canEnablePWAGuide": false,
          "canEnableTrace": false,
          "email": "rudolph.huang@tron.network",
          "firstName": null,
          "fullName": "rudolph.huang@tron.network",
          "hasConversation": false,
          "isOnboard": true,
          "lastName": null,
          "preference": {
            "guide": {
              "topic": true,
              "moveSettingsToAvatar": true
            },
            "telemetry": null,
            "enableGroupChat": false,
            "topicDisplayMode": "flat",
            "useCmdEnterToSend": false,
            "disableInputMarkdownRender": false
          },
          "settings": {
            "defaultAgent": {},
            "general": {},
            "hotkey": {},
            "image": {},
            "keyVaults": {},
            "languageModel": {},
            "systemAgent": {},
            "tool": {},
            "tts": {}
          },
          "userId": "user_6IXMX3AbUl4o",
          "username": null
        },
        "meta": {
          "values": {
            "firstName": ["undefined"],
            "lastName": ["undefined"],
            "username": ["undefined"]
          },
          "v": 1
        }
      }
    }
  }
]
```
