# SessionGroup 会话分组管理接口

管理会话的分组（文件夹）。

## 主要接口

### getSessionGroups

获取所有会话分组。

**类型**: `query`

**权限**: 需要认证

**返回数据**:

```typescript
Array<{
  id: string;
  name: string;
  sort?: number;
  createdAt: string;
  updatedAt: string;
}>
```

---

### createSessionGroup

创建新分组。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  name: string;
  sort?: number;
}
```

**返回数据**: 分组 ID

---

### updateSessionGroup

更新分组信息。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
  name?: string;
  sort?: number;
}
```

---

### removeSessionGroup

删除分组。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  id: string;
}
```

---

## 使用示例

```typescript
// 创建分组
const groupId = await trpc.sessionGroup.createSessionGroup.mutate({
  name: '工作助手',
  sort: 1
});

// 将会话移到分组
await trpc.session.updateSession.mutate({
  id: 'session-id',
  value: { group: groupId }
});

// 获取分组列表
const groups = await trpc.sessionGroup.getSessionGroups.query();
```

详细接口文档参见源码：`src/server/routers/lambda/sessionGroup.ts`
