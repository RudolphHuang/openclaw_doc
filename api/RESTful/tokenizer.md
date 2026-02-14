# POST /webapi/tokenizer

计算文本的令牌数量。

## 接口信息

**方法**: `POST`

**路径**: `/webapi/tokenizer`

**认证**: 可选

**Content-Type**: `application/json`

## 请求体

```typescript
{
  text: string;          // 要计算的文本
  model?: string;        // 模型名称（可选，不同模型使用不同的 tokenizer）
}
```

## 响应

```typescript
{
  count: number;  // 令牌数量
}
```

## 使用示例

```typescript
const response = await fetch('/webapi/tokenizer', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    text: '你好，这是一段测试文本。',
    model: 'gpt-4'
  })
});

const { count } = await response.json();
console.log(`令牌数: ${count}`);
```

## 使用场景

1. **预估费用**: 在发送请求前计算令牌数，估算费用
2. **限制输入**: 确保输入不超过模型限制
3. **优化提示词**: 调整提示词长度以适应上下文窗口

## 支持的模型

- GPT 系列: gpt-3.5-turbo, gpt-4, etc.
- Claude 系列: claude-3-opus, claude-3-sonnet, etc.
- 其他: 自动选择合适的 tokenizer

如果不指定模型，使用默认 tokenizer（GPT-3.5）。
