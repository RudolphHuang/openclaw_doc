# Mobile 移动端接口

移动端使用 Lambda 路由的子集，包括：

## 包含的路由

- `agent` - Agent 管理（完整功能）
- `aiChat` - AI 聊天配置
- `aiModel` - AI 模型管理
- `aiProvider` - AI 提供商管理
- `market` - 市场（Agent、插件）
- `message` - 消息管理
- `session` - 会话管理
- `sessionGroup` - 会话分组
- `topic` - 主题管理

## 使用说明

移动端接口与 Web 端接口完全相同，只是路由路径不同：

- Web 端: `/trpc/lambda.*`
- 移动端: `/trpc/mobile.*`

## 示例

```typescript
// Web 端
await trpc.lambda.session.getSessions.query();

// 移动端
await trpc.mobile.session.getSessions.query();
```

## 为什么需要独立路由？

1. **优化打包体积**: 仅包含移动端需要的路由
2. **性能优化**: 移动端可能有不同的缓存策略
3. **版本管理**: 便于移动端独立升级

详细接口文档参见对应的 Lambda 路由文档。
