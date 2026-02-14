# Group 群组聊天管理接口

群组聊天允许多个 AI Agent 协同对话。

## 主要接口

### createGroup

创建群组聊天。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  title: string;
  description?: string;
  members: string[];  // Agent ID 列表
}
```

---

### getGroupById

获取群组详情。

**类型**: `query`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
}
```

---

### updateGroup

更新群组信息。

**类型**: `mutation`

**权限**: 需要认证

---

### removeGroup

删除群组。

**类型**: `mutation`

**权限**: 需要认证

---

详细接口文档参见源码：`src/server/routers/lambda/group.ts`
