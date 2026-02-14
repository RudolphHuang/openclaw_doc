# Chunk 文本块管理接口

文本块（Chunk）是文件内容的分段，用于向量检索和 RAG。

## 主要接口

### getChunksByFileId

获取指定文件的所有文本块。

**类型**: `query`

**权限**: 需要认证

**输入参数**:

```typescript
{
  fileId: string;
}
```

**返回数据**: 文本块列表

---

### searchChunks

在文本块中执行向量搜索。

**类型**: `query`

**权限**: 需要认证

**输入参数**:

```typescript
{
  query: string;           // 搜索查询
  fileIds?: string[];      // 限定文件范围
  topK?: number;           // 返回结果数量（默认 5）
  minScore?: number;       // 最小相似度分数
}
```

**返回数据**: 相关文本块列表（按相似度排序）

---

### deleteChunksByFileId

删除指定文件的所有文本块。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  fileId: string;
}
```

---

## 使用场景

### RAG 检索

```typescript
// 1. 用户提问
const userQuery = '什么是 LobeChat？';

// 2. 向量搜索相关文本块
const chunks = await trpc.chunk.searchChunks.query({
  query: userQuery,
  topK: 3,
  minScore: 0.7
});

// 3. 将文本块作为上下文发送给 AI
const context = chunks.map(c => c.text).join('\n\n');
const response = await chat({
  messages: [
    { role: 'system', content: `参考以下信息回答:\n${context}` },
    { role: 'user', content: userQuery }
  ]
});
```

详细接口文档参见源码：`src/server/routers/lambda/chunk.ts`
