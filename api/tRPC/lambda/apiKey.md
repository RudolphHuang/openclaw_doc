# API Key 管理接口

管理用户的 API Key，包括创建、查询、更新和删除等操作。

## 主要接口

### getApiKeys

获取当前用户的所有 API Key 列表。

**类型**: `query`

**权限**: 需要认证

**输入参数**: 无

**HTTP 示例**:

```bash
# GET，batch=1，无入参时 input 为 {"0":{"json":null,"meta":{"values":["undefined"],"v":1}}}
curl 'https://chat-dev.ainft.com/trpc/lambda/apiKey.getApiKeys?batch=1&input=%7B%220%22%3A%7B%22json%22%3Anull%2C%22meta%22%3A%7B%22values%22%3A%5B%22undefined%22%5D%2C%22v%22%3A1%7D%7D%7D' \
  -H 'accept: */*' \
  -H 'x-ainft-chat-auth: YOUR_AUTH_TOKEN'
```

**返回数据**:

```typescript
Array<{
  id: number;              // API Key ID
  name: string;            // API Key 名称
  key: string;             // API Key（脱敏显示）
  enabled: boolean;        // 是否启用
  expiresAt: string | null; // 过期时间（ISO 格式），null 表示永不过期
  lastUsedAt: string;      // 最后使用时间（ISO 格式）
  userId: string;          // 所属用户 ID
  accessedAt: string;      // 首次访问时间（ISO 格式）
  createdAt: string;       // 创建时间（ISO 格式）
  updatedAt: string;       // 更新时间（ISO 格式）
}>
```

**返回示例**:

```json
[
  {
    "id": 303,
    "name": "111",
    "key": "sk-1xld3***********************uqmq",
    "enabled": true,
    "expiresAt": null,
    "lastUsedAt": "2026-02-12T17:21:29.293Z",
    "userId": "TMujsbV6t2weXmoPrdfc8QAMJ3oZCJFBXo",
    "accessedAt": "2026-02-12T13:38:31.838Z",
    "createdAt": "2026-02-12T13:38:31.838Z",
    "updatedAt": "2026-02-12T17:21:29.293Z"
  },
  {
    "id": 230,
    "name": "test",
    "key": "sk-hy9j2***********************hl7p",
    "enabled": true,
    "expiresAt": null,
    "lastUsedAt": "2026-02-12T13:37:52.396Z",
    "userId": "TMujsbV6t2weXmoPrdfc8QAMJ3oZCJFBXo",
    "accessedAt": "2026-02-05T07:47:37.873Z",
    "createdAt": "2026-02-05T07:47:37.873Z",
    "updatedAt": "2026-02-12T13:37:52.397Z"
  }
]
```

**说明**: 
- 返回的 `key` 字段为脱敏格式，仅显示前几位和后几位
- tRPC 调用约定（base 路径、batch、input 格式、认证）见 [tRPC README](../README.md)

---

### deleteApiKey

删除指定的 API Key。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: number;  // API Key ID
}
```

**HTTP 示例**:

```bash
# POST，batch=1
curl --location 'https://chat-dev.ainft.com/trpc/lambda/apiKey.deleteApiKey?batch=1' \
  -H 'Content-Type: application/json' \
  -H 'x-ainft-chat-auth: YOUR_AUTH_TOKEN' \
  --data '{"0":{"json":{"id":258}}}'
```

**返回数据**:

```typescript
{
  command: string;      // SQL 命令类型，如 "DELETE"
  rowCount: number;     // 影响的行数
  oid: null;
  rows: any[];          // 返回的行数据
  fields: any[];        // 字段信息
  _types: object;
  RowCtor: null;
  rowAsArray: boolean;
  _prebuiltEmptyResultObject: null;
}
```

**返回示例**:

```json
{
  "command": "DELETE",
  "rowCount": 1,
  "oid": null,
  "rows": [],
  "fields": [],
  "_types": {},
  "RowCtor": null,
  "rowAsArray": false,
  "_prebuiltEmptyResultObject": null
}
```

**说明**:
- `rowCount` 为 1 表示成功删除一条记录
- 删除后该 API Key 立即失效，无法继续使用

---

详细接口文档参见源码：`src/server/routers/lambda/apiKey.ts`
