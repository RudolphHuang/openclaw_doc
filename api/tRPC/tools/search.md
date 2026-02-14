# Tools Search 搜索工具接口

搜索工具接口用于集成外部搜索服务（如 Google、Bing、DuckDuckGo 等）。

## 接口列表

### search

执行搜索查询。

**类型**: `mutation`

**权限**: 公开（publicProcedure）

**输入参数**:

```typescript
{
  query: string;                    // 搜索关键词
  provider?: string;                // 搜索提供商（可选）
  count?: number;                   // 返回结果数量（默认 10）
  offset?: number;                  // 结果偏移量（分页）
  locale?: string;                  // 语言/地区（如 'zh-CN'）
  safeSearch?: 'off' | 'moderate' | 'strict';  // 安全搜索级别
}
```

**返回数据**:

```typescript
{
  results: Array<{
    title: string;
    url: string;
    description: string;
    favicon?: string;
    thumbnail?: string;
  }>;
  total?: number;                   // 总结果数
  provider: string;                 // 实际使用的提供商
}
```

---

## 支持的搜索提供商

### Google Search

需要配置：

- `GOOGLE_SEARCH_API_KEY`
- `GOOGLE_SEARCH_ENGINE_ID`

### Bing Search

需要配置：

- `BING_SEARCH_API_KEY`

### DuckDuckGo

无需配置，免费使用。

### Searxng

需要配置：

- `SEARXNG_BASE_URL`

---

## 使用示例

### 基础搜索

```typescript
const result = await trpc.tools.search.mutate({
  query: 'LobeChat AI 框架'
});

console.log(`找到 ${result.results.length} 个结果`);

result.results.forEach((item, index) => {
  console.log(`${index + 1}. ${item.title}`);
  console.log(`   ${item.url}`);
  console.log(`   ${item.description}`);
});
```

### 指定搜索提供商

```typescript
// 使用 Google 搜索
const googleResult = await trpc.tools.search.mutate({
  query: 'AI chat framework',
  provider: 'google',
  count: 5
});

// 使用 DuckDuckGo
const ddgResult = await trpc.tools.search.mutate({
  query: 'AI chat framework',
  provider: 'duckduckgo',
  count: 10
});
```

### 分页搜索

```typescript
// 第一页
const page1 = await trpc.tools.search.mutate({
  query: 'TypeScript tutorial',
  count: 10,
  offset: 0
});

// 第二页
const page2 = await trpc.tools.search.mutate({
  query: 'TypeScript tutorial',
  count: 10,
  offset: 10
});
```

### 设置语言和地区

```typescript
const result = await trpc.tools.search.mutate({
  query: '人工智能',
  locale: 'zh-CN',
  count: 10
});
```

### 安全搜索

```typescript
const result = await trpc.tools.search.mutate({
  query: 'sensitive topic',
  safeSearch: 'strict'  // 启用严格安全搜索
});
```

---

## Agent 集成示例

### 在 AI 对话中使用搜索

```typescript
// Agent 工具配置
const searchTool = {
  type: 'function',
  function: {
    name: 'web_search',
    description: '在互联网上搜索信息',
    parameters: {
      type: 'object',
      properties: {
        query: {
          type: 'string',
          description: '搜索关键词'
        }
      },
      required: ['query']
    }
  }
};

// Agent 调用搜索工具
async function handleToolCall(toolCall: any) {
  if (toolCall.function.name === 'web_search') {
    const args = JSON.parse(toolCall.function.arguments);
    
    const searchResult = await trpc.tools.search.mutate({
      query: args.query,
      count: 5
    });
    
    // 格式化搜索结果
    const formattedResults = searchResult.results.map((r, i) => 
      `${i + 1}. ${r.title}\n   ${r.description}\n   来源: ${r.url}`
    ).join('\n\n');
    
    return {
      role: 'tool',
      tool_call_id: toolCall.id,
      content: formattedResults
    };
  }
}
```

### 搜索增强的对话

```typescript
async function chatWithSearch(userMessage: string) {
  // 1. 发送用户消息
  const messages = [
    { role: 'user', content: userMessage }
  ];
  
  // 2. AI 决定是否需要搜索
  const aiResponse = await chat({
    messages,
    tools: [searchTool],
    tool_choice: 'auto'
  });
  
  // 3. 如果 AI 调用搜索工具
  if (aiResponse.tool_calls) {
    for (const toolCall of aiResponse.tool_calls) {
      const toolResult = await handleToolCall(toolCall);
      messages.push(aiResponse);
      messages.push(toolResult);
    }
    
    // 4. 基于搜索结果生成最终回复
    const finalResponse = await chat({ messages });
    return finalResponse;
  }
  
  return aiResponse;
}

// 使用示例
const response = await chatWithSearch('LobeChat 的最新功能有哪些？');
```

---

## 高级用法

### 多提供商降级

```typescript
async function searchWithFallback(query: string) {
  const providers = ['google', 'bing', 'duckduckgo'];
  
  for (const provider of providers) {
    try {
      const result = await trpc.tools.search.mutate({
        query,
        provider,
        count: 10
      });
      
      if (result.results.length > 0) {
        return result;
      }
    } catch (error) {
      console.warn(`${provider} 搜索失败，尝试下一个...`);
    }
  }
  
  throw new Error('所有搜索提供商都失败了');
}
```

### 搜索结果去重

```typescript
async function searchWithDedup(query: string) {
  const result = await trpc.tools.search.mutate({ query, count: 20 });
  
  const seen = new Set<string>();
  const uniqueResults = result.results.filter(item => {
    const key = item.url.toLowerCase();
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
  
  return { ...result, results: uniqueResults };
}
```

### 搜索结果评分

```typescript
function scoreSearchResult(result: any, query: string): number {
  let score = 0;
  
  const queryLower = query.toLowerCase();
  const titleLower = result.title.toLowerCase();
  const descLower = result.description.toLowerCase();
  
  // 标题匹配加分
  if (titleLower.includes(queryLower)) score += 10;
  
  // 描述匹配加分
  if (descLower.includes(queryLower)) score += 5;
  
  // URL 可信度加分
  if (result.url.includes('github.com')) score += 3;
  if (result.url.includes('.edu')) score += 2;
  if (result.url.includes('.gov')) score += 2;
  
  return score;
}

async function searchAndRank(query: string) {
  const result = await trpc.tools.search.mutate({ query, count: 20 });
  
  // 评分并排序
  const scored = result.results.map(r => ({
    ...r,
    score: scoreSearchResult(r, query)
  }));
  
  scored.sort((a, b) => b.score - a.score);
  
  return scored.slice(0, 10);  // 返回前 10 个
}
```

### 搜索结果摘要

```typescript
async function searchAndSummarize(query: string) {
  // 1. 执行搜索
  const searchResult = await trpc.tools.search.mutate({
    query,
    count: 5
  });
  
  // 2. 提取摘要
  const summaries = searchResult.results.map(r => r.description).join('\n\n');
  
  // 3. 使用 AI 生成总结
  const summary = await chat({
    messages: [
      {
        role: 'system',
        content: '请根据以下搜索结果，生成一个简洁的摘要。'
      },
      {
        role: 'user',
        content: `查询: ${query}\n\n搜索结果:\n${summaries}`
      }
    ]
  });
  
  return {
    query,
    results: searchResult.results,
    summary: summary.content
  };
}
```

---

## 配置

### 环境变量

```bash
# Google Search
GOOGLE_SEARCH_API_KEY=your-api-key
GOOGLE_SEARCH_ENGINE_ID=your-engine-id

# Bing Search
BING_SEARCH_API_KEY=your-api-key

# Searxng
SEARXNG_BASE_URL=https://your-searxng-instance.com
```

### 默认提供商

如果未指定 `provider`，系统会按以下顺序选择：

1. Google（如果已配置）
2. Bing（如果已配置）
3. DuckDuckGo（默认）

---

## 最佳实践

### 1. 缓存搜索结果

```typescript
const searchCache = new Map<string, any>();
const CACHE_TTL = 1000 * 60 * 30;  // 30 分钟

async function cachedSearch(query: string) {
  const cacheKey = `search:${query}`;
  const cached = searchCache.get(cacheKey);
  
  if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
    return cached.result;
  }
  
  const result = await trpc.tools.search.mutate({ query });
  
  searchCache.set(cacheKey, {
    result,
    timestamp: Date.now()
  });
  
  return result;
}
```

### 2. 查询优化

```typescript
function optimizeQuery(query: string): string {
  // 移除停用词
  const stopWords = ['的', '了', '是', '在', '我'];
  let optimized = query;
  
  stopWords.forEach(word => {
    optimized = optimized.replace(new RegExp(word, 'g'), '');
  });
  
  // 清理多余空格
  optimized = optimized.trim().replace(/\s+/g, ' ');
  
  return optimized;
}

const result = await trpc.tools.search.mutate({
  query: optimizeQuery(userQuery)
});
```

### 3. 速率限制

```typescript
import pLimit from 'p-limit';

const limit = pLimit(5);  // 最多 5 个并发搜索

async function batchSearch(queries: string[]) {
  return Promise.all(
    queries.map(query =>
      limit(() => trpc.tools.search.mutate({ query }))
    )
  );
}
```

---

## 故障排查

### 搜索无结果

1. 检查查询关键词是否有效
2. 尝试更换搜索提供商
3. 检查 API 配额是否用尽

### API 错误

1. 验证环境变量配置
2. 检查 API Key 是否有效
3. 查看提供商服务状态

### 性能问题

1. 减少返回结果数量
2. 启用结果缓存
3. 使用更快的提供商（DuckDuckGo）
