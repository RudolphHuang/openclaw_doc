# Async File 文件异步处理接口

文件异步处理接口用于执行耗时的文件分块（chunking）和向量嵌入（embedding）任务。

## 接口列表

### parseFileToChunks

将文件解析为文本块（chunks）。

**类型**: `mutation`

**权限**: 需要认证（asyncAuthedProcedure）

**输入参数**:

```typescript
{
  fileId: string;
  taskId: string;  // 异步任务 ID
}
```

**返回数据**:

```typescript
{
  success: boolean;
  message?: string;  // 失败时的错误信息
}
```

**说明**:

- 支持的文件类型：PDF、Word、Markdown、TXT 等
- 超时时间：根据 `ASYNC_TASK_TIMEOUT` 配置（默认较长时间）
- 任务状态会自动更新到数据库
- 如果启用了自动嵌入（`CHUNKS_AUTO_EMBEDDING`），会自动触发嵌入任务

**处理流程**:

1. 从存储获取文件内容
2. 根据文件类型选择分块策略
3. 生成文本块并保存到数据库
4. 更新任务状态为 `success` 或 `error`
5. 可选：自动触发嵌入任务

**错误类型**:

- `BAD_REQUEST`: 文件或任务不存在
- `Timeout`: 分块任务超时
- `NoChunkError`: 无法从文件中提取分块
- 其他分块引擎错误

---

### embeddingChunks

为文件的文本块生成向量嵌入。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  fileId: string;
  taskId: string;  // 异步任务 ID
}
```

**返回数据**:

```typescript
{
  success: boolean;
  message?: string;  // 失败时的错误信息
}
```

**说明**:

- 使用系统配置的嵌入模型（默认配置在服务端）
- 批量处理：每批 50 个分块
- 并发数：10 个请求
- 超时时间：根据 `ASYNC_TASK_TIMEOUT` 配置
- 向量维度：1024（可配置）

**处理流程**:

1. 获取文件的所有文本块
2. 按批次调用嵌入模型
3. 保存嵌入向量到数据库
4. 更新任务状态

**错误类型**:

- `BAD_REQUEST`: 文件或任务不存在
- `Timeout`: 嵌入任务超时
- `EmbeddingError`: 嵌入模型调用失败

---

## 使用示例

### 手动触发文件分块

```typescript
// 1. 创建异步任务记录（假设通过其他接口）
const taskId = await createAsyncTask({
  type: 'chunking',
  fileId: 'file-id'
});

// 2. 触发分块
const result = await trpc.async.file.parseFileToChunks.mutate({
  fileId: 'file-id',
  taskId: taskId
});

if (result.success) {
  console.log('✅ 分块成功');
} else {
  console.log(`❌ 分块失败: ${result.message}`);
}
```

### 手动触发向量嵌入

```typescript
// 1. 确保文件已完成分块
const file = await trpc.file.getFileItemById.query({ id: 'file-id' });

if (file.chunkingStatus !== 'success') {
  console.log('文件未完成分块');
  return;
}

// 2. 创建嵌入任务
const taskId = await createAsyncTask({
  type: 'embedding',
  fileId: 'file-id'
});

// 3. 触发嵌入
const result = await trpc.async.file.embeddingChunks.mutate({
  fileId: 'file-id',
  taskId: taskId
});

if (result.success) {
  console.log('✅ 嵌入成功');
}
```

### 完整的文件处理流程

```typescript
async function processFile(fileId: string) {
  try {
    // 步骤 1: 创建分块任务
    const chunkTaskId = await createAsyncTask({
      type: 'chunking',
      fileId: fileId
    });
    
    console.log('开始分块...');
    const chunkResult = await trpc.async.file.parseFileToChunks.mutate({
      fileId,
      taskId: chunkTaskId
    });
    
    if (!chunkResult.success) {
      throw new Error(chunkResult.message);
    }
    
    console.log('✅ 分块完成');
    
    // 步骤 2: 创建嵌入任务
    const embeddingTaskId = await createAsyncTask({
      type: 'embedding',
      fileId: fileId
    });
    
    console.log('开始生成嵌入...');
    const embeddingResult = await trpc.async.file.embeddingChunks.mutate({
      fileId,
      taskId: embeddingTaskId
    });
    
    if (!embeddingResult.success) {
      throw new Error(embeddingResult.message);
    }
    
    console.log('✅ 嵌入完成');
    console.log('🎉 文件处理完成，可用于 RAG 检索');
    
  } catch (error) {
    console.error('❌ 处理失败:', error);
  }
}
```

### 监控异步任务状态

```typescript
async function monitorAsyncTask(fileId: string) {
  const maxRetries = 30;
  const interval = 2000; // 2秒
  
  for (let i = 0; i < maxRetries; i++) {
    const file = await trpc.file.getFileItemById.query({ id: fileId });
    
    // 检查分块状态
    if (file.chunkingStatus === 'processing') {
      console.log('⏳ 分块中...');
    } else if (file.chunkingStatus === 'success') {
      console.log('✅ 分块完成');
      
      // 检查嵌入状态
      if (file.embeddingStatus === 'processing') {
        console.log('⏳ 嵌入中...');
      } else if (file.embeddingStatus === 'success') {
        console.log('✅ 嵌入完成');
        console.log(`📊 共 ${file.chunkCount} 个分块`);
        return { success: true };
      } else if (file.embeddingStatus === 'error') {
        console.error('❌ 嵌入失败:', file.embeddingError);
        return { success: false, error: file.embeddingError };
      }
    } else if (file.chunkingStatus === 'error') {
      console.error('❌ 分块失败:', file.chunkingError);
      return { success: false, error: file.chunkingError };
    }
    
    await new Promise(resolve => setTimeout(resolve, interval));
  }
  
  console.log('⏱️ 超时');
  return { success: false, error: 'Timeout' };
}
```

### 错误处理和重试

```typescript
async function processFileWithRetry(
  fileId: string,
  maxRetries = 3
) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      console.log(`尝试 ${attempt}/${maxRetries}`);
      
      // 分块
      const chunkTaskId = await createAsyncTask({
        type: 'chunking',
        fileId
      });
      
      const chunkResult = await trpc.async.file.parseFileToChunks.mutate({
        fileId,
        taskId: chunkTaskId
      });
      
      if (!chunkResult.success) {
        throw new Error(`分块失败: ${chunkResult.message}`);
      }
      
      // 嵌入
      const embeddingTaskId = await createAsyncTask({
        type: 'embedding',
        fileId
      });
      
      const embeddingResult = await trpc.async.file.embeddingChunks.mutate({
        fileId,
        taskId: embeddingTaskId
      });
      
      if (!embeddingResult.success) {
        throw new Error(`嵌入失败: ${embeddingResult.message}`);
      }
      
      console.log('✅ 处理成功');
      return { success: true };
      
    } catch (error) {
      console.error(`❌ 第 ${attempt} 次尝试失败:`, error);
      
      if (attempt < maxRetries) {
        // 清理失败的任务
        await trpc.file.removeFileAsyncTask.mutate({
          id: fileId,
          type: 'chunk'
        });
        await trpc.file.removeFileAsyncTask.mutate({
          id: fileId,
          type: 'embedding'
        });
        
        // 等待后重试
        await new Promise(resolve => setTimeout(resolve, 5000));
      } else {
        return { success: false, error };
      }
    }
  }
}
```

---

## 配置说明

### 嵌入模型配置

服务端配置在 `getServerDefaultFilesConfig().embeddingModel`：

```typescript
{
  provider: 'openai',  // 或其他提供商
  model: 'text-embedding-3-small'
}
```

### 分块参数

默认分块参数：

- **CHUNK_SIZE**: 50 个分块/批次
- **CONCURRENCY**: 10 个并发请求
- **向量维度**: 1024

### 自动嵌入

通过环境变量控制：

```bash
CHUNKS_AUTO_EMBEDDING=true  # 分块完成后自动触发嵌入
```

---

## 错误类型

### 分块错误

- `Timeout`: 分块超时
- `NoChunkError`: 无法提取分块（文件格式不支持或内容为空）
- `NoSuchKey`: 文件不存在于存储中

### 嵌入错误

- `Timeout`: 嵌入超时
- `EmbeddingError`: 模型调用失败（API 错误、配额不足等）

---

## 最佳实践

### 1. 批量处理文件

```typescript
async function batchProcessFiles(fileIds: string[]) {
  const results = await Promise.allSettled(
    fileIds.map(fileId => processFileWithRetry(fileId))
  );
  
  const success = results.filter(r => r.status === 'fulfilled').length;
  const failed = results.filter(r => r.status === 'rejected').length;
  
  console.log(`✅ 成功: ${success}, ❌ 失败: ${failed}`);
}
```

### 2. 优先级队列

```typescript
// 高优先级文件先处理
async function processFilesWithPriority(
  highPriorityIds: string[],
  normalPriorityIds: string[]
) {
  // 先处理高优先级
  await Promise.all(highPriorityIds.map(id => processFile(id)));
  
  // 再处理普通优先级
  await Promise.all(normalPriorityIds.map(id => processFile(id)));
}
```

### 3. 资源管理

```typescript
// 限制并发数避免资源耗尽
async function processFilesWithConcurrency(
  fileIds: string[],
  concurrency = 5
) {
  const queue = [...fileIds];
  const running: Promise<any>[] = [];
  
  while (queue.length > 0 || running.length > 0) {
    while (running.length < concurrency && queue.length > 0) {
      const fileId = queue.shift()!;
      const task = processFile(fileId).finally(() => {
        running.splice(running.indexOf(task), 1);
      });
      running.push(task);
    }
    
    await Promise.race(running);
  }
}
```
