# TRON 区块链充值接口（当前系统）

ainft 平台基于 TRON 区块链实现的充值系统，支持多种加密货币充值。

## 系统架构

```
[用户钱包] --转账--> [平台接收地址]
                           ↓
                    [TronGrid 扫描器]
                           ↓
                    [交易确认（3 个区块）]
                           ↓
                    [汇率计算]
                           ↓
                    [充值积分到用户账户]
                           ↓
                    [发送通知]
```

---

## 支持的币种

| 币种 | 类型 | 最小充值 | 积分奖励 |
|------|------|----------|----------|
| TRX | 原生 | 1 TRX | 按汇率 |
| USDT | TRC20 | 1 USDT | 按汇率 |
| USDD | TRC20 | 1 USDD | 按汇率 |
| USD1 | TRC20 | 1 USD1 | 按汇率 |
| NFT | TRC20 | 100,000 NFT | 按汇率 + 20% 奖励 |

**积分计算规则**:
```
基础积分 = 美元价值 × 1,000,000
NFT 额外奖励 = 基础积分 × 20%
```

**示例**:
- 充值 10 TRX（价值 $2）→ 2,000,000 积分
- 充值 100,000 NFT（价值 $10）→ 10,000,000 × 1.2 = 12,000,000 积分

---

## 接口列表

### listOrders

获取充值订单列表。

**类型**: `query`

**路径**: `trpc.order.listOrders`

**权限**: 需要认证

**输入参数**:

```typescript
{
  page?: number;           // 页码（默认 1）
  pageSize?: number;       // 每页数量（默认 20，最大 100）
  sortBy?: 'createdAt' | 'points';  // 排序字段（默认 createdAt）
  order?: 'asc' | 'desc';  // 排序方向（默认 desc）
}
```

**返回数据**:

```typescript
{
  data: Array<{
    id: number;
    type: 'recharge';
    currency: string;       // 币种名称（TRX, USDT, etc.）
    quantity: number;       // 充值数量
    points: number;         // 获得积分
    status: 'paid' | 'failed';
    tx_hash: string;        // 交易哈希
    createdAt: number;      // 时间戳（秒）
  }>;
  page: number;
  pageSize: number;
  total: number;            // 总记录数
}
```

---

## 充值流程

### 1. 获取平台接收地址

**环境变量**:
```bash
TRON_RECEIVER_ADDRESS=TxxxxxxxxxxxxxxxxxxxxxxxxxxxxL
```

**前端显示**:

```tsx
'use client';

export function RechargeAddress() {
  const receiverAddress = process.env.NEXT_PUBLIC_TRON_RECEIVER_ADDRESS;
  
  return (
    <div className="p-6 bg-gray-50 rounded-lg">
      <h3 className="text-lg font-semibold mb-2">充值地址</h3>
      <div className="flex items-center gap-2">
        <code className="flex-1 p-3 bg-white rounded border">
          {receiverAddress}
        </code>
        <button
          onClick={() => navigator.clipboard.writeText(receiverAddress)}
          className="px-4 py-2 bg-blue-600 text-white rounded"
        >
          复制
        </button>
      </div>
      <p className="mt-2 text-sm text-gray-600">
        仅支持 TRON 主网，请勿使用其他网络
      </p>
    </div>
  );
}
```

### 2. 用户转账

使用 TronLink 或其他 TRON 钱包转账到平台地址。

**前端示例**（使用 TronLink）:

```typescript
import { rechargeTrx, rechargeTRC20, waitTransactionConfirm } from '@/WalletClient/recharge';

// TRX 充值
export async function rechargeTRX(amount: number) {
  const receiverAddress = process.env.NEXT_PUBLIC_TRON_RECEIVER_ADDRESS!;
  const userAddress = window.tronLink.tronWeb.defaultAddress.base58;
  const amountSun = amount * 1_000_000;  // 转换为 Sun

  try {
    // 发起转账
    const result = await rechargeTrx(receiverAddress, amountSun, userAddress);
    
    if (!result.result) {
      throw new Error('转账失败');
    }

    const txHash = result.txid || result.transaction?.txID;
    console.log('交易哈希:', txHash);

    // 等待确认
    const { status } = await waitTransactionConfirm(txHash);
    
    if (status) {
      alert('✅ 充值成功！积分将在 3-5 分钟内到账');
    } else {
      alert('❌ 交易失败');
    }

    return { success: status, txHash };
  } catch (error) {
    console.error('充值错误:', error);
    alert('充值失败: ' + error.message);
    return { success: false };
  }
}

// USDT 充值
export async function rechargeUSDT(amount: number) {
  const receiverAddress = process.env.NEXT_PUBLIC_TRON_RECEIVER_ADDRESS!;
  const userAddress = window.tronLink.tronWeb.defaultAddress.base58;
  const usdtContract = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t';  // USDT TRC20
  const amountSmallest = amount * 1_000_000;  // USDT 6 位小数

  try {
    const result = await rechargeTRC20(
      usdtContract,
      receiverAddress,
      amountSmallest,
      userAddress
    );

    const txHash = result.txid || result.transaction?.txID;
    const { status } = await waitTransactionConfirm(txHash);

    if (status) {
      alert('✅ USDT 充值成功！');
    }

    return { success: status, txHash };
  } catch (error) {
    console.error('USDT 充值错误:', error);
    return { success: false };
  }
}
```

### 3. 后端自动处理

**扫描器运行**:

后端定时扫描器自动监听链上交易：

```typescript
// 每 30 秒扫描一次
setInterval(async () => {
  const result = await runTronScanner();
  console.log('扫描完成:', result);
}, 30000);
```

**处理流程**:

1. 从 TronGrid API 获取最新交易
2. 过滤到平台接收地址的交易
3. 等待 3 个区块确认
4. 验证币种是否在白名单
5. 查询实时汇率
6. 计算积分（1 USD = 1,000,000 积分）
7. 充值到用户账户
8. 发送通知（PostHog 事件）

**代码位置**: `src/server/services/recharge/tron.ts`

### 4. 查询充值记录

```typescript
// 获取充值记录
const orders = await trpc.order.listOrders.query({
  page: 1,
  pageSize: 20,
  sortBy: 'createdAt',
  order: 'desc'
});

console.log(`共 ${orders.total} 条充值记录`);

orders.data.forEach(order => {
  console.log(`${order.currency}: ${order.quantity} → ${order.points} 积分`);
  console.log(`交易哈希: ${order.tx_hash}`);
  console.log(`状态: ${order.status}`);
});
```

---

## 完整充值组件示例

```tsx
'use client';

import { useState } from 'react';
import { rechargeTRX, rechargeUSDT } from '@/WalletClient/recharge';

const USDT_CONTRACT = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t';

export function TronRechargePanel() {
  const [amount, setAmount] = useState<number>(10);
  const [currency, setCurrency] = useState<'TRX' | 'USDT'>('USDT');
  const [loading, setLoading] = useState(false);

  const receiverAddress = process.env.NEXT_PUBLIC_TRON_RECEIVER_ADDRESS!;

  // 计算预估积分（假设 TRX = $0.2, USDT = $1）
  const estimatedPoints = currency === 'TRX' 
    ? Math.floor(amount * 0.2 * 1_000_000)
    : Math.floor(amount * 1_000_000);

  const handleRecharge = async () => {
    if (!window.tronLink) {
      alert('请先安装 TronLink 钱包');
      return;
    }

    setLoading(true);

    try {
      let result;
      
      if (currency === 'TRX') {
        result = await rechargeTRX(amount);
      } else {
        result = await rechargeUSDT(amount);
      }

      if (result.success) {
        alert(`✅ 充值成功！\n交易哈希: ${result.txHash}\n积分将在 3-5 分钟内到账`);
      }
    } catch (error) {
      alert('充值失败: ' + error.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-md mx-auto p-6 bg-white rounded-lg shadow">
      <h2 className="text-2xl font-bold mb-6">TRON 充值</h2>

      {/* 接收地址 */}
      <div className="mb-6">
        <label className="block text-sm font-medium mb-2">
          充值地址
        </label>
        <div className="flex gap-2">
          <input
            type="text"
            value={receiverAddress}
            readOnly
            className="flex-1 px-3 py-2 border rounded bg-gray-50"
          />
          <button
            onClick={() => navigator.clipboard.writeText(receiverAddress)}
            className="px-4 py-2 bg-gray-200 rounded hover:bg-gray-300"
          >
            复制
          </button>
        </div>
      </div>

      {/* 币种选择 */}
      <div className="mb-6">
        <label className="block text-sm font-medium mb-2">
          选择币种
        </label>
        <div className="flex gap-2">
          <button
            onClick={() => setCurrency('TRX')}
            className={`flex-1 py-2 px-4 rounded ${
              currency === 'TRX' 
                ? 'bg-red-600 text-white' 
                : 'bg-gray-200'
            }`}
          >
            TRX
          </button>
          <button
            onClick={() => setCurrency('USDT')}
            className={`flex-1 py-2 px-4 rounded ${
              currency === 'USDT' 
                ? 'bg-green-600 text-white' 
                : 'bg-gray-200'
            }`}
          >
            USDT
          </button>
        </div>
      </div>

      {/* 金额输入 */}
      <div className="mb-6">
        <label className="block text-sm font-medium mb-2">
          充值数量
        </label>
        <input
          type="number"
          value={amount}
          onChange={(e) => setAmount(Number(e.target.value))}
          min="1"
          className="w-full px-3 py-2 border rounded"
        />
        <p className="mt-2 text-sm text-gray-600">
          预估获得: <strong>{estimatedPoints.toLocaleString()}</strong> 积分
        </p>
      </div>

      {/* 充值按钮 */}
      <button
        onClick={handleRecharge}
        disabled={loading || amount <= 0}
        className="w-full py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:bg-gray-400"
      >
        {loading ? '处理中...' : `充值 ${amount} ${currency}`}
      </button>

      {/* 说明 */}
      <div className="mt-6 p-4 bg-yellow-50 rounded">
        <h4 className="font-semibold text-yellow-800 mb-2">⚠️ 重要提示</h4>
        <ul className="text-sm text-yellow-700 space-y-1">
          <li>• 仅支持 TRON 主网</li>
          <li>• 最小充值: {currency === 'TRX' ? '1 TRX' : '1 USDT'}</li>
          <li>• 到账时间: 3-5 分钟（需要 3 个区块确认）</li>
          <li>• NFT 代币充值有 20% 积分奖励</li>
        </ul>
      </div>
    </div>
  );
}
```

---

## 充值记录查询

### 接口调用

```typescript
import { trpc } from '@/utils/trpc';

// 获取最近的充值记录
const { data, total } = await trpc.order.listOrders.query({
  page: 1,
  pageSize: 10,
  sortBy: 'createdAt',
  order: 'desc'
});

console.log(`共 ${total} 条充值记录`);
```

### 充值记录组件

```tsx
'use client';

import { useQuery } from '@tanstack/react-query';
import { trpc } from '@/utils/trpc';

export function RechargeHistory() {
  const { data, isLoading } = useQuery({
    queryKey: ['orders'],
    queryFn: () => trpc.order.listOrders.query({ page: 1, pageSize: 20 }),
  });

  if (isLoading) return <div>加载中...</div>;

  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
              时间
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
              币种
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
              数量
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
              积分
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
              状态
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
              交易
            </th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {data?.data.map((order) => (
            <tr key={order.id}>
              <td className="px-6 py-4 whitespace-nowrap text-sm">
                {new Date(order.createdAt * 1000).toLocaleString()}
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <span className="px-2 py-1 text-xs font-semibold rounded bg-blue-100 text-blue-800">
                  {order.currency}
                </span>
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm">
                {order.quantity.toFixed(6)}
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                +{order.points.toLocaleString()}
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <span className={`px-2 py-1 text-xs font-semibold rounded ${
                  order.status === 'paid' 
                    ? 'bg-green-100 text-green-800' 
                    : 'bg-red-100 text-red-800'
                }`}>
                  {order.status === 'paid' ? '成功' : '失败'}
                </span>
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm">
                <a
                  href={`https://tronscan.org/#/transaction/${order.tx_hash}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-blue-600 hover:underline"
                >
                  查看交易
                </a>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
```

---

## 技术细节

### 交易扫描

**扫描间隔**: 30 秒（可配置）

**确认要求**: 3 个区块确认（约 9 秒）

**扫描范围**:
- 原生 TRX 转账（TransferContract）
- TRC20 代币转账（Transfer Event）

**代码位置**: `src/server/services/recharge/tron.ts`

### 汇率获取

**API**: `https://api-gateway.apenft.io/api/v1/crypto/price`

**支持的交易对**:
- TRX-USD
- USDT-USD (1:1)
- USDD-USD
- USD1-TRX × TRX-USD (间接)
- NFT-USD

**汇率刷新**: 每次扫描时实时获取

### TRC20 合约白名单

通过环境变量配置允许的 TRC20 合约：

```bash
TRON_TRC20_CONTRACTS="TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t,TMwFHYXLJaRUPeW6421aqXL4ZEzPRFGkGT"
```

**已知合约地址**:
- USDT: `TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t`
- USDD: `TPYmHEhy5n8TCEfYGqW2rPxsghSfzghPDn`

### 积分计算

```typescript
// 1 USD = 1,000,000 积分
const CENTS_TO_POINTS_MULTIPLIER = 10_000;

// 基础积分
const usdCents = Math.trunc(price * quantity * 100);
const basePoints = usdCents * CENTS_TO_POINTS_MULTIPLIER;

// NFT 代币额外 20% 奖励
const isNFT = tokenSymbol === 'NFT';
const multiplier = isNFT ? 1.2 : 1;
const finalPoints = Math.floor(basePoints * multiplier);
```

---

## 监控和日志

### PostHog 事件

充值成功后自动上报事件：

```typescript
captureRechargeSuccess(db, {
  userId: 'TxxxxxxxxxxxL',
  chain: 'TRON',
  tokenName: 'USDT',
  tokenAmount: 100,
  recharge_tx_hash: '0x123...',
});
```

### 日志级别

```typescript
pino.info('[TronScanner] 扫描完成');
pino.warn('[TronScanner] 价格获取失败');
pino.error('[TronScanner] 扫描异常');
```

---

## 故障排查

### 问题 1: 充值未到账

**排查步骤**:

1. 检查交易是否成功：
   ```
   访问 https://tronscan.org/#/transaction/{tx_hash}
   确认状态为 "SUCCESS"
   ```

2. 检查确认数：
   ```
   需要至少 3 个区块确认
   当前确认数 = 最新区块 - 交易区块
   ```

3. 检查接收地址：
   ```
   确认转账到了正确的平台地址
   ```

4. 检查金额：
   ```
   TRX: 至少 1 TRX
   USDT: 至少 1 USDT
   NFT: 至少 100,000 NFT
   ```

5. 检查合约地址（TRC20）：
   ```
   确认合约在白名单中
   ```

### 问题 2: 交易失败

**常见原因**:

- 能量/带宽不足
- 余额不足（包括手续费）
- 网络拥堵
- 合约错误

**解决方法**:

```typescript
// 检查账户资源
const account = await tronWeb.trx.getAccount(userAddress);
console.log('能量:', account.account_resource?.energy_usage);
console.log('带宽:', account.bandwidth);

// 如果资源不足，可以租赁或冻结 TRX
```

### 问题 3: 扫描器停止

**症状**: 长时间未检测到充值

**排查**:

```bash
# 检查扫描器状态
curl https://your-domain.com/api/internal/scanner/status

# 检查日志
tail -f /var/log/ainft/scanner.log
```

**解决**: 重启扫描器或检查 TronGrid API 配额

---

## 优化建议

### 1. 降低确认数要求

**当前**: 3 个区块（约 9 秒）  
**建议**: 1 个区块（约 3 秒）

**风险**: 极小概率的区块重组

```typescript
// 修改确认要求
const MIN_CONFIRMATIONS = 1;  // 改为 1

if (latestBlockNumber - blockNumber >= MIN_CONFIRMATIONS) {
  // 处理充值
}
```

### 2. 实时通知

添加 WebSocket 推送充值到账通知：

```typescript
// 后端
import { Server } from 'socket.io';

const io = new Server(server);

// 充值到账后推送
io.to(userId).emit('recharge:success', {
  points,
  txHash,
  timestamp: Date.now(),
});

// 前端
socket.on('recharge:success', (data) => {
  toast.success(`✅ 充值成功！获得 ${data.points} 积分`);
  // 刷新余额
  refetchBalance();
});
```

### 3. 支持更多币种

添加以太坊、BSC 等其他链的支持：

```typescript
// 配置多链支持
const chains = [
  { name: 'TRON', scanner: runTronScanner },
  { name: 'Ethereum', scanner: runEthScanner },
  { name: 'BSC', scanner: runBscScanner },
];

// 并行扫描
await Promise.all(chains.map(chain => chain.scanner()));
```

### 4. 充值缓存失效

充值后立即清除相关缓存：

```typescript
// 当前实现
import { invalidateRechargeCache } from './userRechargeService';
await invalidateRechargeCache(userId);

// 同时清除积分缓存
import { getCreditsBalanceFromRedis } from './redisCredits';
await redis.del(`credits:${userId}`);
```

---

## 安全考虑

### 1. 防止重复充值

```typescript
// 检查交易哈希是否已处理
const exists = await RechargeModel.existsByTxHash(db, txHash);
if (exists) {
  console.log('交易已处理，跳过');
  return;
}
```

### 2. 金额验证

```typescript
// 最小金额限制
if (amount < minAmount) {
  console.log('金额过小，跳过');
  return;
}
```

### 3. 合约白名单

```typescript
// 只处理白名单合约
const allowedContracts = getAllowedTrc20Contracts();
if (!allowedContracts.includes(contractAddress)) {
  console.log('合约不在白名单，跳过');
  return;
}
```

### 4. 区块确认

```typescript
// 必须等待足够的确认数
const confirmations = latestBlock - txBlock;
if (confirmations < MIN_CONFIRMATIONS) {
  console.log('确认数不足，等待');
  return;
}
```

---

## 用户教程

### 如何充值 TRX

1. 打开 TronLink 钱包
2. 点击"发送"
3. 输入平台地址: `TxxxxxxxxxxxxxxxxxxxxxxxxxxxxL`
4. 输入金额（至少 1 TRX）
5. 确认并发送
6. 等待 3-5 分钟到账

### 如何充值 USDT

1. 打开 TronLink 钱包
2. 切换到 USDT (TRC20)
3. 点击"发送"
4. 输入平台地址
5. 输入金额（至少 1 USDT）
6. 确认并发送（需要消耗能量）
7. 等待 3-5 分钟到账

---

## 常见问题

### Q: 为什么选择 TRON 而不是以太坊？

A: TRON 的优势：
- ⚡ 更快（3 秒出块 vs 以太坊 12 秒）
- 💰 更便宜（手续费 ~$0.01 vs 以太坊 $1-10）
- 🔄 更高效（2000 TPS vs 以太坊 15 TPS）

### Q: 为什么需要 3 个区块确认？

A: 防止区块链重组攻击。3 个确认（约 9 秒）是安全性和速度的平衡。

### Q: NFT 代币为什么有奖励？

A: 鼓励用户使用平台代币，增强生态系统。

### Q: 充值失败如何退款？

A: 区块链交易不可撤销。如果转账成功但未到账，请联系客服，提供交易哈希。

### Q: 支持测试网吗？

A: 生产环境仅支持主网。开发环境可配置测试网（Nile/Shasta）。

---

## 相关接口

- [order.listOrders](../tRPC/lambda/order.md) - 查询充值记录
- [user.getUserState](../tRPC/lambda/user.md) - 查询积分余额
- [user.claimSignupBonus](../tRPC/lambda/user.md) - 领取注册奖励

---

## 环境变量

```bash
# TRON 配置
TRON_RECEIVER_ADDRESS=TxxxxxxxxxxxxxxxxxxxxxxxxxxxxL
TRONGRID_BASE_URL=https://api.trongrid.io
TRONGRID_API_KEY=your-api-key

# TRC20 合约白名单（逗号分隔）
TRON_TRC20_CONTRACTS="TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t,TPYmHEhy5n8TCEfYGqW2rPxsghSfzghPDn"

# 前端使用
NEXT_PUBLIC_TRON_RECEIVER_ADDRESS=TxxxxxxxxxxxxxxxxxxxxxxxxxxxxL
```

---

最后更新: 2026-02-14
