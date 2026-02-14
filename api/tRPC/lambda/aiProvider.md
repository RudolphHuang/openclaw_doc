# AI Provider AI 提供商管理接口

管理 AI 服务提供商配置。

## 主要接口

### getAIProviders

获取所有 AI 提供商列表。

**类型**: `query`

**权限**: 需要认证

**返回数据**:

```typescript
Array<{
  id: string;
  name: string;
  displayName?: string;
  description?: string;
  logo?: string;
  enabled?: boolean;
  requiresApiKey?: boolean;
}>
```

---

### enableAIProvider

启用指定提供商。

**类型**: `mutation`

**权限**: 需要认证

---

### configureAIProvider

配置提供商（如 API Key、Base URL 等）。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  providerId: string;
  config: {
    apiKey?: string;
    baseURL?: string;
    // ... 其他配置
  };
}
```

---

## 使用示例

```typescript
// 配置 OpenAI
await trpc.aiProvider.configureAIProvider.mutate({
  providerId: 'openai',
  config: {
    apiKey: 'sk-...',
    baseURL: 'https://api.openai.com/v1'
  }
});

// 启用提供商
await trpc.aiProvider.enableAIProvider.mutate({
  providerId: 'openai'
});
```

详细接口文档参见源码：`src/server/routers/lambda/aiProvider.ts`
