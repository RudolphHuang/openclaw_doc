# AI Model AI 模型管理接口

管理用户可用的 AI 模型列表。

## 主要接口

### getAIModels

获取所有 AI 模型列表。

**类型**: `query`

**权限**: 需要认证

**返回数据**:

```typescript
Array<{
  id: string;
  name: string;
  provider: string;
  displayName?: string;
  description?: string;
  contextWindow?: number;
  maxOutput?: number;
  pricing?: {
    input: number;   // 输入价格（每 1k tokens）
    output: number;  // 输出价格（每 1k tokens）
  };
  enabled?: boolean;
}>
```

---

### enableAIModel

启用指定模型。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
}
```

---

### disableAIModel

禁用指定模型。

**类型**: `mutation`

**权限**: 需要认证

---

## 使用示例

```typescript
// 获取所有模型
const models = await trpc.aiModel.getAIModels.query();

// 筛选可用模型
const availableModels = models.filter(m => m.enabled);

// 按提供商分组
const byProvider = models.reduce((acc, model) => {
  if (!acc[model.provider]) acc[model.provider] = [];
  acc[model.provider].push(model);
  return acc;
}, {});
```

详细接口文档参见源码：`src/server/routers/lambda/aiModel.ts`
