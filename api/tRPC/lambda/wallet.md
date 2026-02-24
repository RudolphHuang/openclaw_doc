# Wallet 钱包管理接口

管理用户绑定的钱包地址，支持多种区块链钱包的绑定和验证。

## 主要接口

### linkWalletAddress

绑定钱包地址到当前用户账户。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  address: string;      // 钱包地址
  chain: string;        // 区块链类型，如 "tron"、"bnb"、"eth"
  message: string;      // 签名消息（包含地址、Chain ID、过期时间、Nonce）
  provider: string;     // 钱包提供商，如 "tronlink"、"binance"
  signature: string;    // 钱包签名（十六进制字符串，以 0x 开头）
  version: string;      // 签名版本，如 "2"
}
```

**签名消息格式**:

```
Welcome to AINFT !
https://chat-dev.ainft.com wants you to sign in with your TRON account:
{wallet_address}

Chain ID: {chain_id}
Expiration Time: {iso_timestamp}
Nonce: {random_nonce}
```

**HTTP 示例**:

```bash
curl 'https://chat-dev.ainft.com/trpc/lambda/wallet.linkWalletAddress?batch=1' \
  -H 'accept: */*' \
  -H 'content-type: application/json' \
  -H 'origin: https://chat-dev.ainft.com' \
  -H 'referer: https://chat-dev.ainft.com/chat' \
  -H 'x-ainft-chat-auth: YOUR_AUTH_TOKEN' \
  --data-raw '{
    "0": {
      "json": {
        "address": "TRTUCXKtr6hFsp4vERmzCv3URCXkykM8Pk",
        "chain": "tron",
        "message": "Welcome to AINFT !\nhttps://chat-dev.ainft.com wants you to sign in with your TRON account:\nTRTUCXKtr6hFsp4vERmzCv3URCXkykM8Pk\n\nChain ID: 0x2b6653dc\nExpiration Time: 2026-02-25T06:50:30.077Z\nNonce: TL8XYX1771915825077",
        "provider": "tronlink",
        "signature": "0xc34fac844aa25af809ec99a7df3528e71eef331f293a0bec15b03622ee67de7a55c3d1bc6b9ab0083f50a5bf9325d79e10f40502212dde05f7d4dcd3a127b3791c",
        "version": "2"
      }
    }
  }'
```

**返回数据**:

```typescript
{
  success: boolean;     // 是否绑定成功
  message?: string;     // 提示信息
}
```

**说明**:

- 需要通过钱包签名验证地址所有权
- 支持多种区块链：TRON (`tron`)、BSC (`bnb`)、Ethereum (`eth`)
- 同一地址不能重复绑定到同一用户
- 签名消息有过期时间，过期后需要重新签名

**错误**:

- `UNAUTHORIZED`: 用户未认证
- `BAD_REQUEST`: 签名无效、消息过期、地址格式错误
- `CONFLICT`: 地址已被其他用户绑定

---

### unlinkWalletAddress

解绑钱包地址。

**类型**: `mutation`

**权限**: 需要认证

**输入参数**:

```typescript
{
  address: string;   // 钱包地址
  chain: string;     // 区块链类型，如 "tron"、"bnb"、"eth"
}
```

**HTTP 示例**:

```bash
curl 'https://chat-dev.ainft.com/trpc/lambda/wallet.unlinkWalletAddress?batch=1' \
  -H 'accept: */*' \
  -H 'content-type: application/json' \
  -H 'origin: https://chat-dev.ainft.com' \
  -H 'referer: https://chat-dev.ainft.com/chat' \
  -H 'x-ainft-chat-auth: YOUR_AUTH_TOKEN' \
  --data-raw '{
    "0": {
      "json": {
        "address": "TRTUCXKtr6hFsp4vERmzCv3URCXkykM8Pk",
        "chain": "tron"
      }
    }
  }'
```

**返回数据**:

```typescript
{
  success: boolean;   // 是否解绑成功
}
```

**返回示例**:

```json
{
  "result": {
    "data": {
      "json": {
        "success": true
      }
    }
  }
}
```

**说明**:
- 解绑后该钱包地址将不再与当前用户关联
- 解绑后可以使用该地址绑定到其他账户
```

---

### getLinkedWalletAddresses

获取当前用户已绑定的钱包地址列表。

**类型**: `query`

**权限**: 需要认证

**输入参数**: 无

**HTTP 示例**:

```bash
# GET，batch=1，无入参时 input 为 {"0":{"json":null,"meta":{"values":["undefined"],"v":1}}}
curl 'https://chat-dev.ainft.com/trpc/lambda/wallet.getLinkedWalletAddresses?batch=1&input=%7B%220%22%3A%7B%22json%22%3Anull%2C%22meta%22%3A%7B%22values%22%3A%5B%22undefined%22%5D%2C%22v%22%3A1%7D%7D%7D' \
  -H 'accept: */*' \
  -H 'x-ainft-chat-auth: YOUR_AUTH_TOKEN'
```

**返回数据**:

```typescript
{
  addresses: Array<{
    address: string;      // 钱包地址
    chain: string;        // 区块链类型，如 "tron"、"bnb"、"eth"
    createdAt: string;    // 绑定时间（ISO 格式）
  }>;
}
```

**返回示例**:

```json
{
  "result": {
    "data": {
      "json": {
        "addresses": [
          {
            "address": "0x40469Ab4316c3A8A864BdAB1273735BDBC78DbD1",
            "chain": "bnb",
            "createdAt": "2026-02-24T06:49:07.953Z"
          }
        ]
      }
    }
  }
}
```

**说明**:
- 返回当前用户已绑定的所有钱包地址列表
- 每个地址包含区块链类型和绑定时间
- 如果用户未绑定任何钱包，返回空数组

---

## 使用示例

### 绑定 TronLink 钱包

```typescript
// 1. 准备签名消息
const message = `Welcome to AINFT !
https://chat-dev.ainft.com wants you to sign in with your TRON account:
${walletAddress}

Chain ID: 0x2b6653dc
Expiration Time: ${new Date(Date.now() + 5 * 60 * 1000).toISOString()}
Nonce: ${generateRandomNonce()}`;

// 2. 使用 TronLink 签名
const signature = await window.tronLink.sign(message);

// 3. 绑定钱包地址
const result = await trpc.wallet.linkWalletAddress.mutate({
  address: walletAddress,
  chain: 'tron',
  message,
  provider: 'tronlink',
  signature,
  version: '2'
});

if (result.success) {
  console.log('钱包绑定成功');
}
```

### 获取已绑定钱包列表

```typescript
const result = await trpc.wallet.getLinkedWalletAddresses.query();

result.addresses.forEach(wallet => {
  console.log(`${wallet.chain}: ${wallet.address}`);
});
```

---

详细接口文档参见源码：`src/server/routers/lambda/wallet.ts`
