# Market 市场接口

市场提供 Agent 和插件的发现、安装功能。

## 主要接口

### searchAgents

搜索市场中的 Agent。

**类型**: `query`

**权限**: 公开

**输入参数**:

```typescript
{
  keywords?: string;
  category?: string;
  tags?: string[];
  sort?: 'popular' | 'recent' | 'rating';
}
```

**返回数据**: Agent 列表

---

### getAgentById

获取市场 Agent 详情。

**类型**: `query`

**权限**: 公开

**输入参数**:

```typescript
{
  id: string;
}
```

---

### installAgent

从市场安装 Agent。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  agentId: string;
}
```

**返回数据**: 安装后的会话 ID

---

### searchPlugins

搜索市场中的插件。

**类型**: `query`

**权限**: 公开

---

### installPlugin

从市场安装插件。

**类型**: `mutation`

**权限**: 需要认证

---

## 使用示例

```typescript
// 搜索 Agent
const agents = await trpc.market.searchAgents.query({
  keywords: 'coding assistant',
  sort: 'popular'
});

// 安装 Agent
const sessionId = await trpc.market.installAgent.mutate({
  agentId: 'coding-assistant-v1'
});

// 跳转到新会话
router.push(`/chat/${sessionId}`);
```

详细接口文档参见源码：`src/server/routers/lambda/market/index.ts`
