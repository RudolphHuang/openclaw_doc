# Importer 数据导入接口

支持从其他平台导入数据（会话、消息等）。

## 主要接口

### importFromChatGPT

从 ChatGPT 导入数据。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  data: object;  // ChatGPT 导出的 JSON 数据
}
```

**返回数据**:

```typescript
{
  success: boolean;
  importedSessions: number;
  importedMessages: number;
  errors?: string[];
}
```

---

### importFromLegacy

从旧版 LobeChat 导入数据。

**类型**: `mutation`

**权限**: 需要认证

---

详细接口文档参见源码：`src/server/routers/lambda/importer.ts`
