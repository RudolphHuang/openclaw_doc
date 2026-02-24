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

### createS3PreSignedUrl

创建 S3 预签名上传 URL（直接指定文件路径）。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  pathname: string;  // 文件路径，如 "files/{userId}/{filename}"
}
```

**HTTP 示例**:

```bash
# POST，batch=1
curl --location 'https://chat-dev.ainft.com/trpc/lambda/upload.createS3PreSignedUrl?batch=1' \
  -H 'Content-Type: application/json' \
  -H 'x-ainft-chat-auth: YOUR_AUTH_TOKEN' \
  --data '{"0":{"json":{"pathname":"files/492196/bdd31faf-2267-477b-b610-ca05ede31bef.jpg"}}}'
```

**返回数据**:

```typescript
string  // S3 预签名上传 URL（包含临时凭证）
```

**返回示例**:

```json
{
  "result": {
    "data": {
      "json": "https://ainft-chat-dev.s3.ap-southeast-1.amazonaws.com/files/492196/bdd31faf-2267-477b-b610-ca05ede31bef.jpg?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=...&X-Amz-Date=...&X-Amz-Expires=3600&X-Amz-Signature=...&X-Amz-SignedHeaders=host&x-amz-acl=public-read&x-id=PutObject"
    }
  }
}
```

**说明**:
- 返回的 URL 有效期为 3600 秒（1 小时）
- 使用 PUT 方法上传文件到此 URL
- URL 包含 AWS 签名和临时凭证，无需额外认证
- `x-amz-acl=public-read` 表示文件上传后为公开可读

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
