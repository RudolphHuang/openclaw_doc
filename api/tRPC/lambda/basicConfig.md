# BasicConfig 基础配置接口

管理基础系统配置。

## 主要接口

### getBasicConfig

获取基础配置。

**类型**: `query`

**权限**: 公开

**返回数据**:

```typescript
{
  appName: string;
  appLogo?: string;
  appDescription?: string;
  // ... 其他基础配置
}
```

---

详细接口文档参见源码：`src/server/routers/lambda/basicConfig.ts`
