# Usage 使用统计接口

查询用户使用情况统计。

## 主要接口

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
