# Exporter 数据导出接口

将用户数据导出为各种格式。

## 主要接口

### exportAll

导出所有数据。

**类型**: `query`

**权限**: 需要认证

**输入参数**:

```typescript
{
  format?: 'json' | 'markdown';  // 默认 json
}
```

**返回数据**: 导出数据（JSON 或 Markdown）

---

### exportSession

导出指定会话。

**类型**: `query`

**权限**: 需要认证

**输入参数**:

```typescript
{
  sessionId: string;
  format?: 'json' | 'markdown';
}
```

---

详细接口文档参见源码：`src/server/routers/lambda/exporter.ts`
