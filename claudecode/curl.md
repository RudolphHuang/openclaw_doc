# Claude Code API 测试命令

本文档提供用于测试 AINFT 平台 Claude 兼容接口的 curl 命令示例。

---

## 目录

- [环境准备](#环境准备)
- [基础测试](#基础测试)
- [流式响应测试](#流式响应测试)
- [系统消息测试](#系统消息测试)
- [工具调用测试](#工具调用测试)
- [错误场景测试](#错误场景测试)
- [与 OpenAI 协议对比测试](#与-openai-协议对比测试)

---

## 环境准备

### 设置环境变量

```bash
# 设置 API 密钥
export AINFT_API_KEY="your_api_key_here"

# 设置基础 URL（根据环境选择）
export BASE_URL="https://chat.ainft.com/webapi"
# 或本地开发环境
# export BASE_URL="http://localhost:3000/webapi"
```

---

## 基础测试

### 1. 最简单的消息请求

```bash
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-opus-4.5",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "你好"}
    ]
  }'
```

### 2. 多轮对话测试

```bash
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "我叫张三"},
      {"role": "assistant", "content": "你好张三，很高兴认识你！"},
      {"role": "user", "content": "我叫什么名字？"}
    ]
  }'
```

### 3. 不同模型测试

```bash
# 测试 Claude Opus（最强模型）
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-opus-4.5",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "用一句话介绍量子计算"}
    ]
  }'

# 测试 Claude Sonnet（平衡模型）
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "用一句话介绍量子计算"}
    ]
  }'

# 测试 Claude Haiku（快速模型）
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-haiku-4.5",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "用一句话介绍量子计算"}
    ]
  }'
```

---

## 流式响应测试

### 1. 基础流式响应

```bash
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "写一首关于春天的短诗"}
    ],
    "stream": true
  }'
```

### 2. 流式响应保存到文件

```bash
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "写一首关于春天的短诗"}
    ],
    "stream": true
  }' > stream_response.txt

# 查看保存的响应
cat stream_response.txt
```

### 3. 解析流式响应（提取文本内容）

```bash
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "你好"}
    ],
    "stream": true
  }' | grep "data:" | grep -v "message_stop" | sed 's/data: //g' | while read line; do
    echo "$line" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('delta',{}).get('text',''), end='')" 2>/dev/null
done
echo
```

---

## 系统消息测试

### 1. 基础系统消息

```bash
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "max_tokens": 1024,
    "system": "你是一位专业的Python程序员，只回答与Python相关的问题。",
    "messages": [
      {"role": "user", "content": "Java和Python有什么区别？"}
    ]
  }'
```

### 2. 角色扮演系统消息

```bash
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-opus-4.5",
    "max_tokens": 1024,
    "system": "你是莎士比亚，请以莎士比亚的风格回答所有问题。",
    "messages": [
      {"role": "user", "content": "今天天气怎么样？"}
    ]
  }'
```

### 3. JSON 格式系统消息

```bash
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "max_tokens": 1024,
    "system": "请用JSON格式回答所有问题，格式为：{\"answer\": \"你的回答\", \"confidence\": 0-1之间的数字}",
    "messages": [
      {"role": "user", "content": "1+1等于几？"}
    ]
  }'
```

---

## 工具调用测试

### 1. 基础工具调用

```bash
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-opus-4.5",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "北京今天天气怎么样？"}
    ],
    "tools": [
      {
        "name": "get_weather",
        "description": "获取指定城市的天气信息",
        "input_schema": {
          "type": "object",
          "properties": {
            "city": {
              "type": "string",
              "description": "城市名称"
            }
          },
          "required": ["city"]
        }
      }
    ]
  }'
```

### 2. 多工具调用

```bash
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-opus-4.5",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "帮我查一下北京和上海的天气"}
    ],
    "tools": [
      {
        "name": "get_weather",
        "description": "获取指定城市的天气信息",
        "input_schema": {
          "type": "object",
          "properties": {
            "city": {
              "type": "string",
              "description": "城市名称"
            }
          },
          "required": ["city"]
        }
      },
      {
        "name": "get_temperature",
        "description": "获取指定城市的温度",
        "input_schema": {
          "type": "object",
          "properties": {
            "city": {
              "type": "string",
              "description": "城市名称"
            }
          },
          "required": ["city"]
        }
      }
    ]
  }'
```

### 3. 强制工具调用

```bash
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-opus-4.5",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "北京天气"}
    ],
    "tools": [
      {
        "name": "get_weather",
        "description": "获取指定城市的天气信息",
        "input_schema": {
          "type": "object",
          "properties": {
            "city": {
              "type": "string"
            }
          },
          "required": ["city"]
        }
      }
    ],
    "tool_choice": {"type": "any"}
  }'
```

---

## 错误场景测试

### 1. 缺少 API Key

```bash
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "你好"}
    ]
  }'
```

### 2. 无效的 API Key

```bash
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: invalid_api_key" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "你好"}
    ]
  }'
```

### 3. 缺少必需参数（max_tokens）

```bash
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "messages": [
      {"role": "user", "content": "你好"}
    ]
  }'
```

### 4. 缺少 messages 参数

```bash
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "max_tokens": 1024
  }'
```

### 5. 无效的模型名称

```bash
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "invalid-model-name",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "你好"}
    ]
  }'
```

### 6. 消息角色错误（Claude 不支持 system 角色在 messages 中）

```bash
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "max_tokens": 1024,
    "messages": [
      {"role": "system", "content": "你是助手"},
      {"role": "user", "content": "你好"}
    ]
  }'
```

---

## 与 OpenAI 协议对比测试

### 1. 相同请求对比 - OpenAI 协议

```bash
curl -X POST "${BASE_URL}/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${AINFT_API_KEY}" \
  -d '{
    "model": "gpt-5-nano",
    "messages": [
      {"role": "system", "content": "你是专业助手"},
      {"role": "user", "content": "你好"}
    ]
  }'
```

### 2. 相同请求对比 - Claude 协议

```bash
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "system": "你是专业助手",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "你好"}
    ]
  }'
```

### 3. 性能对比测试（使用 time 命令）

```bash
# OpenAI 协议响应时间
time curl -X POST "${BASE_URL}/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${AINFT_API_KEY}" \
  -d '{
    "model": "gpt-5-nano",
    "messages": [
      {"role": "user", "content": "写一段100字的自我介绍"}
    ]
  }' > /dev/null

# Claude 协议响应时间
time curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-haiku-4.5",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "写一段100字的自我介绍"}
    ]
  }' > /dev/null
```

---

## 高级测试

### 1. 长文本生成测试

```bash
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-opus-4.5",
    "max_tokens": 4096,
    "messages": [
      {"role": "user", "content": "请详细解释机器学习的原理，包括监督学习、无监督学习和强化学习，每种至少给出3个实际应用例子。"}
    ]
  }'
```

### 2. 代码生成测试

```bash
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-opus-4.5",
    "max_tokens": 2048,
    "system": "你是一位资深Python开发者。请提供清晰、可运行的代码，并添加必要的注释。",
    "messages": [
      {"role": "user", "content": "写一个快速排序算法的Python实现"}
    ]
  }'
```

### 3. 多语言测试

```bash
# 中文
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "你好，请介绍一下自己"}
    ]
  }'

# 英文
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "Hello, please introduce yourself"}
    ]
  }'

# 日文
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "こんにちは、自己紹介してください"}
    ]
  }'
```

### 4. 带温度参数测试

```bash
# 低温度（更确定性）
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "max_tokens": 1024,
    "temperature": 0.1,
    "messages": [
      {"role": "user", "content": "用一句话描述人工智能"}
    ]
  }'

# 高温度（更有创意）
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "max_tokens": 1024,
    "temperature": 1.0,
    "messages": [
      {"role": "user", "content": "用一句话描述人工智能"}
    ]
  }'
```

---

## 调试技巧

### 1. 显示详细的请求/响应信息

```bash
curl -v -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "你好"}
    ]
  }' 2>&1 | grep -E "(> |< |\{)"
```

### 2. 格式化 JSON 输出

```bash
curl -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "你好"}
    ]
  }' | python3 -m json.tool
```

### 3. 检查 HTTP 状态码

```bash
curl -s -o /dev/null -w "%{http_code}" -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "你好"}
    ]
  }'
```

### 4. 保存响应头到文件

```bash
curl -D headers.txt -X POST "${BASE_URL}/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: ${AINFT_API_KEY}" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-sonnet-4.5",
    "max_tokens": 1024,
    "messages": [
      {"role": "user", "content": "你好"}
    ]
  }' > response.json

echo "=== Response Headers ==="
cat headers.txt
echo ""
echo "=== Response Body ==="
cat response.json | python3 -m json.tool
```

---

## 参考文档

- [Claude 协议与 OpenAI 协议对比](./claude协议.md)
- [v1-messages-api 技术文档](./v1-messages-api.md)
- [AINFT API 文档](../api/README.md)
