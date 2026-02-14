# Config 配置管理接口

管理系统配置。

## 主要接口

### getServerConfig

获取服务端配置（公开）。

**类型**: `query`

**权限**: 公开

**返回数据**:

```typescript
{
  enabledFeatures: string[];
  enabledProviders: string[];
  defaultModel?: string;
  // ... 其他公开配置
}
```

---

### getUserConfig

获取用户配置。

**类型**: `query`

**权限**: 需要认证

---

### updateUserConfig

更新用户配置。

**类型**: `mutation`

**权限**: 需要认证

---

详细接口文档参见源码：`src/server/routers/lambda/config/index.ts`
