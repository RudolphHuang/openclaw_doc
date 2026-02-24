# Order 订单管理接口

管理用户的充值订单，包括查询订单列表、订单详情等。

## 主要接口

### listOrders

获取当前用户的订单列表（分页）。

**类型**: `query`

**权限**: 需要认证

**输入参数**:

```typescript
{
  page?: number;       // 页码，默认 1
  pageSize?: number;   // 每页条数，默认 20
  sortBy?: string;     // 排序字段，如 "createdAt"
  order?: string;      // 排序方向："asc" | "desc"
}
```

**HTTP 示例**:

```bash
# GET，batch=1
curl 'https://chat-dev.ainft.com/trpc/lambda/order.listOrders?batch=1&input=%7B%220%22%3A%7B%22json%22%3A%7B%22page%22%3A1%2C%22pageSize%22%3A20%2C%22sortBy%22%3A%22createdAt%22%2C%22order%22%3A%22desc%22%7D%7D%7D' \
  -H 'accept: */*' \
  -H 'x-ainft-chat-auth: YOUR_AUTH_TOKEN'
```

**返回数据**:

```typescript
{
  data: Array<{
    id: number;           // 订单 ID
    type: string;         // 订单类型，如 "recharge"（充值）
    status: string;       // 订单状态："paid" | "pending" | "failed" 等
    chain: string;        // 区块链类型，如 "tron"
    currency: string;     // 货币类型，如 "TRX"
    quantity: number;     // 充值数量
    points: number;       // 获得积分数量
    tx_hash: string;      // 交易哈希
    createdAt: number;    // 创建时间（Unix 时间戳）
  }>;
  page: number;           // 当前页码
  pageSize: number;       // 每页条数
  total: number;          // 总记录数
}
```

**返回示例**:

```json
{
  "data": [
    {
      "id": 369,
      "type": "recharge",
      "status": "paid",
      "chain": "tron",
      "currency": "TRX",
      "quantity": 5,
      "points": 1370000,
      "tx_hash": "d5e0b4e2ef28ccee5e162fed41bd1137101368fa583f6febcdc807512a361182",
      "createdAt": 1770464513
    },
    {
      "id": 345,
      "type": "recharge",
      "status": "paid",
      "chain": "tron",
      "currency": "TRX",
      "quantity": 5,
      "points": 1410000,
      "tx_hash": "deb0dbe996d87a6ab86c24f1a69b63b1c4b660bc0afa7e62b93c0951ccb4cab0",
      "createdAt": 1770277631
    }
  ],
  "page": 1,
  "pageSize": 20,
  "total": 2
}
```

**字段说明**:

| 字段 | 说明 |
|------|------|
| `type` | 订单类型，`recharge` 表示充值订单 |
| `status` | 订单状态，`paid` 已支付，`pending` 待支付，`failed` 失败 |
| `chain` | 区块链网络，`tron` 表示 TRON 网络 |
| `currency` | 支付货币，`TRX` 表示波场币 |
| `quantity` | 支付的货币数量 |
| `points` | 充值获得的积分数量 |
| `tx_hash` | 区块链交易哈希，可用于在区块链浏览器查询 |
| `createdAt` | 订单创建时间，Unix 时间戳（秒） |

**说明**: tRPC 调用约定（base 路径、batch、input 格式、认证）见 [tRPC README](../README.md)。

---

详细接口文档参见源码：`src/server/routers/lambda/order.ts`
