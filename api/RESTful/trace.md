# POST /webapi/trace

上报追踪数据（OpenTelemetry）。

## 接口信息

**方法**: `POST`

**路径**: `/webapi/trace`

**认证**: 需要 JWT Token

**Content-Type**: `application/json`

## 请求体

```typescript
{
  traceId: string;
  spans: Array<{
    spanId: string;
    parentSpanId?: string;
    name: string;
    kind: 'CLIENT' | 'SERVER' | 'INTERNAL';
    startTime: number;
    endTime: number;
    attributes?: Record<string, any>;
    events?: Array<{
      name: string;
      timestamp: number;
      attributes?: Record<string, any>;
    }>;
  }>;
}
```

## 响应

```typescript
{
  success: boolean;
}
```

## 使用示例

```typescript
await fetch('/webapi/trace', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    traceId: 'trace-123',
    spans: [
      {
        spanId: 'span-1',
        name: 'chat.completion',
        kind: 'CLIENT',
        startTime: Date.now() - 5000,
        endTime: Date.now(),
        attributes: {
          model: 'gpt-4',
          tokens: 1234
        }
      }
    ]
  })
});
```

## 使用场景

- 性能监控
- 错误追踪
- 用户行为分析
- API 调用统计
