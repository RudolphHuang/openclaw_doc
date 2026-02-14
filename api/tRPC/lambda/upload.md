# Upload 上传管理接口

管理文件上传任务。

## 主要接口

### createUploadTask

创建上传任务并获取预签名 URL。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  filename: string;
  fileType: string;
  size: number;
}
```

**返回数据**:

```typescript
{
  uploadUrl: string;     // 预签名上传 URL
  fileKey: string;       // 文件路径
  taskId: string;        // 任务 ID
}
```

---

## 使用示例

```typescript
// 1. 创建上传任务
const { uploadUrl, fileKey } = await trpc.upload.createUploadTask.mutate({
  filename: 'document.pdf',
  fileType: 'application/pdf',
  size: file.size
});

// 2. 上传文件到 S3
await fetch(uploadUrl, {
  method: 'PUT',
  body: file,
  headers: {
    'Content-Type': file.type
  }
});

// 3. 创建文件记录
await trpc.file.createFile.mutate({
  name: file.name,
  fileType: file.type,
  size: file.size,
  url: fileKey
});
```

详细接口文档参见源码：`src/server/routers/lambda/upload.ts`
