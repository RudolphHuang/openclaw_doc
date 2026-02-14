# Usage 使用统计接口

查询用户使用情况统计、积分余额等。

## 主要接口

### points

获取当前用户积分（余额）等信息。

**类型**: `query`

**权限**: 需要认证

**输入参数**: 无

**HTTP 示例**:

```bash
# GET，batch=1，无入参时 input 为 {"0":{"json":null,"meta":{"values":["undefined"],"v":1}}}
curl 'https://chat-dev.ainft.com/trpc/lambda/usage.points?batch=1&input=%7B%220%22%3A%7B%22json%22%3Anull%2C%22meta%22%3A%7B%22values%22%3A%5B%22undefined%22%5D%2C%22v%22%3A1%7D%7D%7D%7D' \
  -H 'accept: */*' \
  -H 'x-ainft-chat-auth: YOUR_AUTH_TOKEN'
```

**说明**: tRPC 调用约定（base 路径、batch、input 格式、认证）见 [tRPC README](../README.md)。

---

### getUsageStats

获取使用统计概览。

**类型**: `query`

**权限**: 需要认证

**输入参数**:

```typescript
{
  startDate?: string;
  endDate?: string;
  range?: [string, string];
}
```

**返回数据**:

```typescript
{
  totalMessages: number;
  totalSessions: number;
  totalTokens: number;
  totalCost: number;
  byModel: Array<{
    model: string;
    count: number;
    tokens: number;
    cost: number;
  }>;
  byDate: Array<{
    date: string;
    count: number;
  }>;
}
```

---

### getTokenUsage

获取令牌使用详情。

**类型**: `query`

**权限**: 需要认证

---

### getCostBreakdown

获取费用明细。

**类型**: `query`

**权限**: 需要认证

---

## 使用示例

```typescript
// 获取本月统计
const stats = await trpc.usage.getUsageStats.query({
  startDate: '2024-01-01',
  endDate: '2024-01-31'
});

console.log(`总消息数: ${stats.totalMessages}`);
console.log(`总令牌数: ${stats.totalTokens}`);
console.log(`总费用: ${stats.totalCost}`);
```

详细接口文档参见源码：`src/server/routers/lambda/usage.ts`
