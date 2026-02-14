# Thread 线程管理接口

线程是群组聊天中的子对话。

## 主要接口

### getThreads

获取线程列表。

**类型**: `query`

**权限**: 需要认证

**输入参数**:

```typescript
{
  groupId?: string;
}
```

---

### createThread

创建新线程。

**类型**: `mutation`

**权限**: 需要认证

---

### updateThread

更新线程。

**类型**: `mutation`

**权限**: 需要认证

---

### removeThread

删除线程。

**类型**: `mutation`

**权限**: 需要认证

---

详细接口文档参见源码：`src/server/routers/lambda/thread.ts`
