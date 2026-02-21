# tRPC 接口说明

## HTTP 调用约定（ainft 实际格式）

ainft 前端通过以下方式调用 tRPC，**直接 HTTP 调用（如 Postman、curl）需按此格式**。

### 1. Base URL 与路径

- **Base**: `https://chat-dev.ainft.com/trpc`
- **Lambda 主业务**: `/trpc/lambda/{router}.{procedure}`  
  示例：`/trpc/lambda/usage.points`、`/trpc/lambda/session.getSessions`
- **Async**: `/trpc/async/...`
- **Tools**: `/trpc/tools/...`  
  详见 [README 主目录](../README.md) 中的路由分组。

### 2. 查询参数（必带）

- **batch=1**  
  表示使用 batch 格式，即使只调一个 procedure 也需带上。
- **input**  
  URL 编码后的 JSON，格式见下。

### 3. input 格式（batch=1）

单次调用时，`input` 为**一个对象**，键为 `"0"`，值为该次调用的入参与元数据：

```typescript
// 无入参（query 无参数）
input = encodeURIComponent(JSON.stringify({
  "0": {
    "json": null,
    "meta": { "values": ["undefined"], "v": 1 }
  }
}));

// 有入参（query/mutation 的 input）
input = encodeURIComponent(JSON.stringify({
  "0": {
    "json": { sessionId: "...", current: 1, pageSize: 20 },
    "meta": { "values": ["undefined"], "v": 1 }
  }
}));
```

多 procedure 批量调用时，可增加 `"1"`、`"2"` 等键，每个键对应一次调用。

### 4. 请求方式

- 一般为 **GET**，入参通过 query 的 `input` 传递（如上）。
- 若入参过大，部分实现可能支持 **POST**，body 为 JSON，格式与上述 `input` 解码后一致（需以实际服务为准）。

### 5. 认证

- **Cookie**：登录后由浏览器自动携带（如 `__Secure-authjs.session-token` 等）。
- **请求头（二选一或同时使用）**：  
  - `x-ainft-chat-auth: <token>`  
  前端从会话或接口拿到的 auth token，可直接用于 Postman/curl。

示例（无入参）：

```bash
curl 'https://chat-dev.ainft.com/trpc/lambda/usage.points?batch=1&input=%7B%220%22%3A%7B%22json%22%3Anull%2C%22meta%22%3A%7B%22values%22%3A%5B%22undefined%22%5D%2C%22v%22%3A1%7D%7D%7D%7D' \
  -H 'accept: */*' \
  -H 'x-ainft-chat-auth: YOUR_AUTH_TOKEN'
```

### 6. 与前端 tRPC 客户端的对应关系

前端写法与 HTTP 的对应关系：

| 前端调用 | HTTP 路径 | input 中 "0".json |
|----------|-----------|-------------------|
| `trpc.usage.points.query()` | GET `/trpc/lambda/usage.points?batch=1&input=...` | null |
| `trpc.session.getSessions.query({ current: 1 })` | GET `.../session.getSessions?batch=1&input=...` | `{ current: 1, pageSize: 20 }` |
| `trpc.session.createSession.mutate({ ... })` | GET（或 POST）`.../session.createSession?batch=1&input=...` | `{ type, session, config }` |

---

## 文档目录（Lambda）

- [user](lambda/user.md) - 用户、设置、积分
- [session](lambda/session.md) - 会话
- [sessionGroup](lambda/sessionGroup.md) - 会话分组
- [message](lambda/message.md) - 消息
- [topic](lambda/topic.md) - 主题
- [agent](lambda/agent.md) - Agent、知识库绑定
- [file](lambda/file.md) / [upload](lambda/upload.md) - 文件与上传
- [knowledgeBase](lambda/knowledgeBase.md) - 知识库
- [usage](lambda/usage.md) - 使用统计、积分（含 points）
- [config](lambda/config.md) - 全局配置（getGlobalConfig、getDefaultAgentConfig）
- 其他见 [主目录 README](../README.md)
