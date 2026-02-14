# KnowledgeBase 知识库管理接口

知识库是文件的集合，用于组织和管理相关文档，可绑定到 Agent 实现 RAG（检索增强生成）。

## 接口列表

### getKnowledgeBases

获取所有知识库列表。

**类型**: `query`

**权限**: 需要认证

**输入参数**: 无

**返回数据**:

```typescript
Array<{
  id: string;
  name: string;
  description?: string;
  avatar?: string;
  createdAt: string;
  updatedAt: string;
}>
```

---

### getKnowledgeBaseById

根据 ID 获取知识库详情。

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
  name: string;
  description?: string;
  avatar?: string;
  createdAt: string;
  updatedAt: string;
} | undefined
```

---

### createKnowledgeBase

创建新知识库。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  name: string;
  description?: string;
  avatar?: string;
}
```

**返回数据**:

```typescript
string // 新知识库 ID
```

---

### updateKnowledgeBase

更新知识库信息。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
  value: {
    name?: string;
    description?: string;
    avatar?: string;
  };
}
```

**返回数据**:

```typescript
void
```

---

### removeKnowledgeBase

删除知识库。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
  removeFiles?: boolean;  // 是否同时删除文件（可选）
}
```

**返回数据**:

```typescript
void
```

**说明**:

- 删除知识库不会自动删除文件
- `removeFiles` 参数当前未使用，文件需要单独管理

---

### removeAllKnowledgeBases

删除所有知识库。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**: 无

**返回数据**:

```typescript
void
```

---

## 文件管理

### addFilesToKnowledgeBase

向知识库添加文件。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  knowledgeBaseId: string;
  ids: string[];  // 文件 ID 列表
}
```

**返回数据**:

```typescript
void
```

---

### removeFilesFromKnowledgeBase

从知识库移除文件。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  knowledgeBaseId: string;
  ids: string[];  // 文件 ID 列表
}
```

**返回数据**:

```typescript
void
```

**说明**:

- 仅解除关联，不会删除文件本身

---

## 使用示例

### 获取所有知识库

```typescript
const knowledgeBases = await trpc.knowledgeBase.getKnowledgeBases.query();

console.log(`共 ${knowledgeBases.length} 个知识库`);
knowledgeBases.forEach(kb => {
  console.log(`- ${kb.name}: ${kb.description}`);
});
```

### 创建知识库

```typescript
const kbId = await trpc.knowledgeBase.createKnowledgeBase.mutate({
  name: '技术文档',
  description: '包含所有技术相关的文档',
  avatar: '📚'
});

console.log(`创建的知识库 ID: ${kbId}`);
```

### 更新知识库

```typescript
await trpc.knowledgeBase.updateKnowledgeBase.mutate({
  id: 'kb-id',
  value: {
    name: '新名称',
    description: '更新后的描述'
  }
});
```

### 添加文件到知识库

```typescript
await trpc.knowledgeBase.addFilesToKnowledgeBase.mutate({
  knowledgeBaseId: 'kb-id',
  ids: ['file-1', 'file-2', 'file-3']
});
```

### 从知识库移除文件

```typescript
await trpc.knowledgeBase.removeFilesFromKnowledgeBase.mutate({
  knowledgeBaseId: 'kb-id',
  ids: ['file-1', 'file-2']
});
```

### 删除知识库

```typescript
await trpc.knowledgeBase.removeKnowledgeBase.mutate({
  id: 'kb-id'
});
```

### 获取知识库详情

```typescript
const kb = await trpc.knowledgeBase.getKnowledgeBaseById.query({
  id: 'kb-id'
});

if (kb) {
  console.log(`知识库: ${kb.name}`);
  console.log(`描述: ${kb.description}`);
}
```

---

## 完整工作流示例

### 创建并配置知识库

```typescript
// 1. 创建知识库
const kbId = await trpc.knowledgeBase.createKnowledgeBase.mutate({
  name: 'API 文档',
  description: '所有 API 相关文档',
  avatar: '📖'
});

// 2. 上传文件（假设已通过文件上传接口上传）
const fileIds = ['file-1', 'file-2', 'file-3'];

// 3. 将文件添加到知识库
await trpc.knowledgeBase.addFilesToKnowledgeBase.mutate({
  knowledgeBaseId: kbId,
  ids: fileIds
});

// 4. 绑定到 Agent
await trpc.agent.createAgentKnowledgeBase.mutate({
  agentId: 'agent-id',
  knowledgeBaseId: kbId,
  enabled: true
});

console.log('知识库配置完成！');
```

### 管理知识库文件

```typescript
// 获取知识库
const kb = await trpc.knowledgeBase.getKnowledgeBaseById.query({
  id: 'kb-id'
});

// 获取知识库中的文件
const files = await trpc.file.getFiles.query({
  knowledgeBaseId: 'kb-id'
});

console.log(`知识库 "${kb.name}" 包含 ${files.length} 个文件`);

// 移除不需要的文件
const filesToRemove = files.filter(f => f.size > 10 * 1024 * 1024); // > 10MB
if (filesToRemove.length > 0) {
  await trpc.knowledgeBase.removeFilesFromKnowledgeBase.mutate({
    knowledgeBaseId: 'kb-id',
    ids: filesToRemove.map(f => f.id)
  });
  console.log(`移除了 ${filesToRemove.length} 个大文件`);
}
```

### 知识库迁移

```typescript
// 从旧知识库迁移文件到新知识库
async function migrateKnowledgeBase(oldKbId: string, newKbId: string) {
  // 1. 获取旧知识库的文件
  const files = await trpc.file.getFiles.query({
    knowledgeBaseId: oldKbId
  });
  
  const fileIds = files.map(f => f.id);
  
  // 2. 添加到新知识库
  await trpc.knowledgeBase.addFilesToKnowledgeBase.mutate({
    knowledgeBaseId: newKbId,
    ids: fileIds
  });
  
  // 3. 从旧知识库移除
  await trpc.knowledgeBase.removeFilesFromKnowledgeBase.mutate({
    knowledgeBaseId: oldKbId,
    ids: fileIds
  });
  
  console.log(`迁移完成: ${fileIds.length} 个文件`);
}
```

---

## 数据类型

### KnowledgeBase

```typescript
{
  id: string;
  name: string;
  description?: string;
  avatar?: string;
  createdAt: string;
  updatedAt: string;
}
```

---

## 最佳实践

### 1. 知识库命名规范

```typescript
// 推荐：使用有意义的名称和描述
await trpc.knowledgeBase.createKnowledgeBase.mutate({
  name: '产品文档 - 2024Q1',
  description: '2024年第一季度的产品文档和用户指南',
  avatar: '📦'
});
```

### 2. 定期清理

```typescript
// 定期检查和清理未使用的知识库
const knowledgeBases = await trpc.knowledgeBase.getKnowledgeBases.query();

for (const kb of knowledgeBases) {
  const files = await trpc.file.getFiles.query({
    knowledgeBaseId: kb.id
  });
  
  if (files.length === 0) {
    console.log(`知识库 "${kb.name}" 为空，准备删除`);
    await trpc.knowledgeBase.removeKnowledgeBase.mutate({
      id: kb.id
    });
  }
}
```

### 3. 知识库分类

```typescript
// 按类别组织知识库
const categories = {
  tech: { name: '技术文档', avatar: '💻' },
  business: { name: '商业文档', avatar: '📊' },
  legal: { name: '法律文档', avatar: '⚖️' }
};

for (const [key, value] of Object.entries(categories)) {
  await trpc.knowledgeBase.createKnowledgeBase.mutate({
    name: value.name,
    avatar: value.avatar,
    description: `${value.name}知识库`
  });
}
```
