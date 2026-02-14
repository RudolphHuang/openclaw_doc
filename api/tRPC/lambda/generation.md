# Generation 图像生成接口

管理图像生成任务。

## 主要接口

### createGeneration

创建图像生成任务。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  prompt: string;                // 提示词
  model?: string;                // 模型
  provider?: string;             // 提供商
  size?: string;                 // 尺寸（如 '1024x1024'）
  style?: string;                // 风格
  quality?: 'standard' | 'hd';   // 质量
  n?: number;                    // 生成数量
}
```

**返回数据**: 任务 ID

---

### getGenerationById

获取生成任务详情。

**类型**: `query`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
}
```

**返回数据**:

```typescript
{
  id: string;
  status: 'pending' | 'processing' | 'success' | 'error';
  prompt: string;
  images?: string[];  // 生成的图像 URL
  error?: string;
  createdAt: string;
  updatedAt: string;
}
```

---

### getGenerations

获取生成任务列表。

**类型**: `query`

**权限**: 需要认证

---

### deleteGeneration

删除生成任务。

**类型**: `mutation`

**权限**: 需要认证

---

## 使用示例

```typescript
// 创建生成任务
const taskId = await trpc.generation.createGeneration.mutate({
  prompt: 'a beautiful sunset over the ocean',
  model: 'dall-e-3',
  size: '1024x1024',
  quality: 'hd'
});

// 轮询任务状态
const checkStatus = async () => {
  const task = await trpc.generation.getGenerationById.query({ id: taskId });
  
  if (task.status === 'success') {
    console.log('生成完成:', task.images);
  } else if (task.status === 'error') {
    console.error('生成失败:', task.error);
  } else {
    setTimeout(checkStatus, 2000);
  }
};

await checkStatus();
```

详细接口文档参见源码：`src/server/routers/lambda/generation.ts`
