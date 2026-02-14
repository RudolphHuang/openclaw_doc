# Document 文档管理接口

管理知识库中的文档。

## 主要接口

### getDocuments

获取文档列表。

**类型**: `query`

**权限**: 需要认证

**输入参数**:

```typescript
{
  knowledgeBaseId?: string;
}
```

---

### createDocument

创建文档。

**类型**: `mutation`

**权限**: 需要认证

---

### updateDocument

更新文档。

**类型**: `mutation`

**权限**: 需要认证

---

### removeDocument

删除文档。

**类型**: `mutation`

**权限**: 需要认证

---

详细接口文档参见源码：`src/server/routers/lambda/document.ts`
