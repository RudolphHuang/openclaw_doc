# APENFT 外部 API 接口

APENFT 平台提供的外部 API 接口，用于获取加密货币价格等信息。

**Base URL**: `https://api-gateway.apenft.io`

---

## 获取加密货币价格

### GET /api/v1/crypto/price

**接口说明**: 获取指定交易对的实时价格。

**请求方法**: `GET`

---

### 请求参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `chain` | string | 是 | 区块链类型，如 `tron` |
| `pair` | string | 是 | 交易对，格式为 `{TOKEN}-{CURRENCY}`，如 `NFT-USD` |

---

### 请求示例

```bash
curl 'https://api-gateway.apenft.io/api/v1/crypto/price?chain=tron&pair=NFT-USD' \
  -H 'accept: */*' \
  -H 'origin: https://chat-dev.ainft.com' \
  -H 'referer: https://chat-dev.ainft.com/'
```

---

### 响应数据

| 字段 | 类型 | 说明 |
|------|------|------|
| `code` | number | 状态码，`0` 表示成功 |
| `message` | string | 状态描述，`"ok"` 表示成功 |
| `data` | string | 价格数值，字符串格式的浮点数 |

---

### 响应示例

```json
{
  "code": 0,
  "message": "ok",
  "data": "0.0000003342"
}
```

---

### 支持的参数值

**chain**:
- `tron` - TRON 区块链
- `eth` - Ethereum 区块链
- `bnb` - BSC 区块链

**pair**:
- `NFT-USD` - NFT 代币对 USD
- `TRX-USD` - TRX 对 USD
- `BTC-USD` - BTC 对 USD
- `ETH-USD` - ETH 对 USD

---

### 错误响应

| 状态码 | 说明 |
|--------|------|
| `400` | 参数错误，缺少必填参数或参数格式不正确 |
| `404` | 不支持的交易对 |
| `500` | 服务器内部错误 |

---

### 注意事项

1. **跨域请求**: 该接口支持 CORS，可以从浏览器端直接调用
2. **频率限制**: 建议合理控制请求频率，避免触发限流
3. **价格精度**: 价格数据为字符串格式，避免浮点数精度问题
4. **实时性**: 价格为实时或近实时数据，可能存在短暂延迟

---

### 使用示例

```typescript
// 获取 NFT 代币价格
async function getNFTPrice() {
  const response = await fetch(
    'https://api-gateway.apenft.io/api/v1/crypto/price?chain=tron&pair=NFT-USD'
  );
  const result = await response.json();
  
  if (result.code === 0) {
    const price = parseFloat(result.data);
    console.log(`NFT 价格: $${price}`);
    return price;
  } else {
    console.error('获取价格失败:', result.message);
    return null;
  }
}

// 获取 TRX 价格
async function getTRXPrice() {
  const response = await fetch(
    'https://api-gateway.apenft.io/api/v1/crypto/price?chain=tron&pair=TRX-USD'
  );
  const result = await response.json();
  return result.code === 0 ? parseFloat(result.data) : null;
}
```

---

## 相关链接

- [APENFT 官网](https://apenft.io)
- [APENFT 文档](https://docs.apenft.io)
