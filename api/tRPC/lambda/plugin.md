# Plugin 插件管理接口

管理用户安装的插件。

## 主要接口

### getInstalledPlugins

获取已安装的插件列表。

**类型**: `query`

**权限**: 需要认证

**返回数据**:

```typescript
Array<{
  id: string;
  identifier: string;
  name: string;
  description?: string;
  avatar?: string;
  author?: string;
  enabled?: boolean;
  manifest?: object;
}>
```

---

### installPlugin

安装插件。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  identifier: string;  // 插件标识符
  manifest?: object;   // 插件清单
}
```

---

### uninstallPlugin

卸载插件。

**类型**: `mutation`

**权限**: 需要认证

---

### enablePlugin

启用插件。

**类型**: `mutation`

**权限**: 需要认证

---

### disablePlugin

禁用插件。

**类型**: `mutation`

**权限**: 需要认证

---

详细接口文档参见源码：`src/server/routers/lambda/plugin.ts`
