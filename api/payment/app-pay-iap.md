# App Store In-App Purchase（IAP）技术方案

> **方案 B**：适用于 iOS/macOS 原生 App 内销售数字商品（积分、会员）的唯一合规方式。
>
> **验证机制**：StoreKit 2 + JWS 本地验签（`@apple/app-store-server-library`）。

---

## 架构总览

```mermaid
flowchart TB
    subgraph Client["客户端"]
        iOSApp["iOS/macOS App"]
        StoreKit2["StoreKit 2"]
    end

    subgraph Apple["Apple 生态"]
        AppStore["App Store"]
        AppleRootCA["Apple Root CA\n（本地内置公钥）"]
    end

    subgraph Backend["后端服务"]
        IAPAPI["/trpc/lambda/iap.verifyReceipt"]
        JWSVerifier["SignedDataVerifier\n本地 JWS 验签（无网络请求）"]
        IAPService["IAPService\nsrc/server/services/payment/iap.ts"]
    end

    subgraph Database["数据库"]
        RechargeTable["t_recharge_records\npackages/database/src/models/recharge.ts"]
    end

    iOSApp -->|1. 请求商品| StoreKit2
    StoreKit2 -->|2. 获取商品| AppStore
    iOSApp -->|3. 发起购买| StoreKit2
    StoreKit2 -->|4. 处理支付| AppStore
    AppStore -->|5. 返回 VerificationResult| StoreKit2
    StoreKit2 -->|6. jwsRepresentation| iOSApp
    iOSApp -->|7. 发送 jwsToken| IAPAPI
    IAPAPI -->|8. 验证请求| IAPService
    IAPService -->|9. 本地验签| JWSVerifier
    JWSVerifier -->|10. 对比 Apple Root CA| AppleRootCA
    JWSVerifier -->|11. 返回解码 Payload| IAPService
    IAPService -->|12. 防重放 + 写入充值记录| RechargeTable

    style Client fill:#e3f2fd
    style Apple fill:#f3e5f5
    style Backend fill:#e8f5e9
    style Database fill:#fff3e0
```

---

## 购买时序图

```mermaid
sequenceDiagram
    autonumber
    actor User as 用户
    participant iOS as iOS App
    participant StoreKit as StoreKit 2
    participant AppStore as App Store
    participant Backend as 后端 tRPC
    participant JWSVerifier as SignedDataVerifier
    participant DB as PostgreSQL

    User->>iOS: 点击购买积分
    iOS->>StoreKit: product.purchase()
    StoreKit->>AppStore: 请求支付
    AppStore->>User: 显示支付确认（Face ID / Touch ID）
    User->>AppStore: 确认支付
    AppStore-->>StoreKit: 返回 VerificationResult<Transaction>
    StoreKit-->>iOS: .success(verification)

    iOS->>iOS: checkVerified(verification)（StoreKit 本地 JWS 校验）
    iOS->>iOS: 取 transaction.jwsRepresentation

    iOS->>Backend: lambda/iap.verifyReceipt\n{ jwsToken, productId }

    Backend->>DB: existsByTxHash(transactionId)（防重放）
    DB-->>Backend: 不存在，继续处理

    Backend->>JWSVerifier: verifyAndDecodeTransaction(jwsToken)
    Note over JWSVerifier: 本地验证签名链<br/>（无网络请求）
    JWSVerifier-->>Backend: JWSTransactionDecodedPayload\n{ transactionId, productId, environment, purchaseDate, ... }

    Backend->>Backend: 校验 productId / type

    alt 验证成功
        Backend->>DB: INSERT t_recharge_records\n{ chain:'apple-iap', txHash:transactionId, tokenName:'usd', ... }
        Backend-->>iOS: { success: true, transactionId }
        iOS->>StoreKit: transaction.finish()
        iOS-->>User: 显示充值成功
    else JWS 验签失败 / 字段不匹配 / 重放攻击
        Backend-->>iOS: 返回失败（4xx）
        iOS-->>User: 显示错误提示
    end
```

---

## 商品配置

在 App Store Connect 中配置消耗型（Consumable）商品：

| Product ID | 类型 | 价格 | 积分 |
|---|---|---|---|
| `com.ainft.points.10` | Consumable | $9.99 | 10,000,000 |
| `com.ainft.points.50` | Consumable | $49.99 | 50,000,000 |
| `com.ainft.points.100` | Consumable | $99.99 | 100,000,000 |

---

## 后端实现

### 文件路径总览

| 文件 | 说明 |
|---|---|
| `packages/database/src/models/recharge.ts` | RechargeModel（复用，写入 `t_recharge_records`） |
| `src/server/services/payment/iap.ts` | 业务逻辑服务（JWS 验签 + 充值记录写入） |
| `src/server/routers/lambda/iap.ts` | tRPC 路由定义 |
| `src/server/routers/lambda/index.ts` | 主路由注册（新增 `iap: iapRouter`） |

### 依赖安装

```bash
pnpm add @apple/app-store-server-library
```

---

### 1. RechargeModel 字段映射

IAP 充值复用现有 `t_recharge_records` 表，字段映射如下：

| `t_recharge_records` 字段 | IAP 写入值 | 说明 |
|---|---|---|
| `chain` | `'apple-iap'` | 固定值，区分链路来源 |
| `txHash` | `payload.transactionId` | Apple 交易 ID，用于防重放唯一检查 |
| `tokenName` | `'usd'` | 固定值 |
| `amount` | 价格（美分） | 如 $9.99 → `999` |
| `usdAmount` | 价格（美分） | 同 amount |
| `userId` | 当前登录用户 ID | 从会话获取 |
| `userAddress` | `userId` | IAP 无钱包地址，用 userId 占位 |
| `receiverAddress` | `'apple-app-store'` | 固定占位符 |
| `blockNumber` | `0` | IAP 无区块概念，填 0 |
| `confirmedAt` | `new Date(payload.purchaseDate)` | 购买时间即确认时间 |
| `createdAt` | `new Date()` | 写入时间 |

> `RechargeModel.existsByTxHash(db, transactionId)` 用于防重放检查，`txHash` 在表中有索引。

> **注意**：`RechargeInsert` 类型中 `chain` 当前约束为 `'tron'`，需扩展为 `'tron' | 'apple-iap'`。

---

### 2. IAP 服务

**文件**: `src/server/services/payment/iap.ts`

#### 初始化 SignedDataVerifier

```typescript
import {
  Environment,
  SignedDataVerifier,
} from '@apple/app-store-server-library';
import * as fs from 'fs';
import * as path from 'path';

// Apple Root CA 证书（从 Apple 官网下载后放入项目 certs/ 目录）
// https://www.apple.com/certificateauthority/
const appleRootCAs: Buffer[] = [
  fs.readFileSync(path.resolve('certs/AppleRootCA-G3.cer')),
  fs.readFileSync(path.resolve('certs/AppleIncRootCertificate.cer')),
];

const BUNDLE_ID = 'com.ainft.app';  // 与 App Store Connect 中一致

// App Apple ID：App Store Connect > 我的 App > 通用 > Apple ID（纯数字）
const APP_APPLE_ID = Number(process.env.APP_APPLE_ID);

function createVerifier(environment: Environment): SignedDataVerifier {
  // 生产环境强制要求 appAppleId，沙盒环境可省略
  // 参见库源码：if (environment === PRODUCTION && appAppleId === undefined) throw
  const appAppleId = environment === Environment.PRODUCTION ? APP_APPLE_ID : undefined;
  return new SignedDataVerifier(
    appleRootCAs,
    true,           // enableOnlineChecks：启用 OCSP 吊销检查
    environment,
    BUNDLE_ID,
    appAppleId,
  );
}
```

> **证书说明**：`AppleRootCA-G3.cer` 和 `AppleIncRootCertificate.cer` 从 [Apple PKI 页面](https://www.apple.com/certificateauthority/) 下载，提交到代码仓库的 `certs/` 目录（非密钥，属公开证书，可安全提交）。

#### 商品配置（静态配置）

```typescript
const IAP_PRODUCT_CONFIGS: Record<string, { currency: string; points: number; price: number }> = {
  'com.ainft.points.10':  { currency: 'USD', points: 10_000_000,  price: 999  },
  'com.ainft.points.50':  { currency: 'USD', points: 50_000_000,  price: 4999 },
  'com.ainft.points.100': { currency: 'USD', points: 100_000_000, price: 9999 },
};
```

#### 核心方法：`processPurchase`

```typescript
async processPurchase(params: {
  userId: string;
  jwsToken: string;   // transaction.jwsRepresentation
  productId: string;  // 用于前置合法性校验
}): Promise<{ success: boolean; transactionId: string }>
```

**处理流程**：

```typescript
async processPurchase({ userId, jwsToken, productId }) {
  // 1. 前置校验 productId
  const config = IAP_PRODUCT_CONFIGS[productId];
  if (!config) throw new Error('Unknown product ID');

  // 2. 先尝试生产环境验签；若抛出 VerificationException，再尝试沙盒环境
  let payload: JWSTransactionDecodedPayload;

  try {
    payload = await createVerifier(Environment.PRODUCTION).verifyAndDecodeTransaction(jwsToken);
  } catch {
    payload = await createVerifier(Environment.SANDBOX).verifyAndDecodeTransaction(jwsToken);
  }

  // 3. 校验 Payload 业务字段
  // bundleId 已由 SignedDataVerifier 内部校验（不匹配时抛 INVALID_APP_IDENTIFIER）
  if (payload.productId !== productId) throw new Error('Product ID mismatch');
  if (payload.type !== 'Consumable') throw new Error('Unexpected product type');

  const { transactionId, purchaseDate } = payload;

  // 4. 防重放检查（txHash = Apple transactionId）
  const exists = await RechargeModel.existsByTxHash(db, transactionId);
  if (exists) throw new Error('Transaction already processed');

  // 5. 写入充值记录
  await RechargeModel.insert(db, {
    userId,
    chain: 'apple-iap',
    txHash: transactionId,
    tokenName: 'usd',
    amount: config.price,                          // 单位：美分
    usdAmount: config.price,                       // 单位：美分
    userAddress: userId,                           // IAP 无钱包地址，用 userId 占位
    receiverAddress: 'apple-app-store',            // 固定占位符
    blockNumber: 0,                                // IAP 无区块概念
    confirmedAt: purchaseDate ? new Date(purchaseDate) : new Date(),
    createdAt: new Date(),
  });

  return { success: true, transactionId };
}
```

#### JWS 验签说明

```
验签由 @apple/app-store-server-library 的 SignedDataVerifier 完成：
  1. 解析 JWS Header 中的 x5c（X.509 证书链，固定 3 段）
  2. 验证证书链是否锚定到内置的 Apple Root CA
  3. 使用叶证书的公钥验证 JWS 签名（ES256/ECDSA）
  4. 校验叶证书和中间证书在当前时间仍有效（enableOnlineChecks=true 时使用当前时间）
  5. 执行 OCSP 吊销检查（enableOnlineChecks=true）
  6. 校验 bundleId 与构造时传入的 bundleId 一致，否则抛 INVALID_APP_IDENTIFIER
  7. 校验 payload.environment 与构造时传入的 environment 一致，否则抛 INVALID_ENVIRONMENT
  8. 返回解码后的 JWSTransactionDecodedPayload

环境区分：
  - 先用 PRODUCTION 验证器尝试，若抛 VerificationException(INVALID_ENVIRONMENT)
    则说明是 Sandbox Token，改用 Sandbox 验证器重试
  - payload.environment 枚举值：'Production' | 'Sandbox'
```

#### JWSTransactionDecodedPayload 关键字段

| 字段 | 类型 | 说明 |
|---|---|---|
| `transactionId` | string | 本次交易唯一 ID（防重放键） |
| `originalTransactionId` | string | 原始交易 ID（订阅场景） |
| `bundleId` | string | App Bundle ID，需与后端配置一致 |
| `productId` | string | 商品 ID |
| `type` | string | `Consumable` / `Non-Consumable` / `Auto-Renewable Subscription` |
| `purchaseDate` | number | 购买时间（毫秒时间戳） |
| `quantity` | number | 购买数量 |
| `environment` | string | `Production` / `Sandbox` |
| `inAppOwnershipType` | string | `PURCHASED` / `FAMILY_SHARED` |
| `signedDate` | number | JWS 签发时间（毫秒时间戳） |
| `appAccountToken` | string | 购买时由 App 设置的用户 UUID（可选） |

---

### 3. tRPC 路由

**文件**: `src/server/routers/lambda/iap.ts`

#### `iap.getProducts`

```
GET /trpc/lambda/iap.getProducts
```

返回：
```typescript
Array<{
  productId: string;
  price: number;     // 美分
  currency: string;
  points: number;
}>
```

#### `iap.verifyReceipt`

```
POST /trpc/lambda/iap.verifyReceipt
```

输入：
```typescript
{
  jwsToken: string;   // transaction.jwsRepresentation
  productId: string;  // 如 com.ainft.points.10（用于前置合法性校验）
}
```

> `transactionId` 由后端从 JWS Payload 中解码提取，防止客户端伪造。

返回：
```typescript
{
  success: boolean;
  transactionId: string;
}
```

错误码：
- `Transaction already processed` — 重放攻击，该交易已处理
- `Unknown product ID` — 非法的 productId
- `Product ID mismatch` — JWS Payload 与客户端上报 productId 不一致
- `VerificationException` — JWS 签名验证失败（伪造或过期）

#### 充值历史

IAP 充值记录写入 `t_recharge_records`（`chain='apple-iap'`），历史查询复用现有接口：

```
GET /trpc/lambda/order.listOrders
```

---

### 4. 主路由注册

**文件**: `src/server/routers/lambda/index.ts`

```typescript
import { iapRouter } from './iap';

export const lambdaRouter = router({
  // ...其他路由...
  iap: iapRouter,
  // ...
});
```

---

## 环境变量

```bash
# .env

# App Bundle ID（与 App Store Connect 一致）
APP_BUNDLE_ID=com.ainft.app

# App Apple ID：App Store Connect > 我的 App > 通用 > Apple ID（纯数字）
# 生产环境 SignedDataVerifier 强制要求，缺少则抛异常
APP_APPLE_ID=1234567890
```

---

## Apple Root CA 证书

从 [https://www.apple.com/certificateauthority/](https://www.apple.com/certificateauthority/) 下载并放入项目 `certs/` 目录：

```
certs/
├── AppleRootCA-G3.cer          # Apple Root CA - G3（主要）
└── AppleIncRootCertificate.cer # Apple Inc Root Certificate（兼容旧版）
```

```bash
# 下载脚本（一次性操作）
mkdir -p certs
curl -o certs/AppleRootCA-G3.cer \
  https://www.apple.com/certificateauthority/AppleRootCA-G3.cer
curl -o certs/AppleIncRootCertificate.cer \
  https://www.apple.com/certificateauthority/AppleIncRootCertificate.cer
```

> 这些是 Apple 公开发布的根证书，属于公钥基础设施（PKI）的公开部分，可以安全提交到代码仓库。

---

## iOS 前端集成（Swift）

### StoreKit 2 购买管理器

```swift
import StoreKit

class IAPManager: ObservableObject {
    @Published var products: [Product] = []

    func loadProducts() async {
        products = (try? await Product.products(for: [
            "com.ainft.points.10",
            "com.ainft.points.50",
            "com.ainft.points.100",
        ])) ?? []
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)

            await verifyOnBackend(transaction: transaction, productId: product.id)

            // 后端验证成功后再 finish，确保积分已发放
            await transaction.finish()

        case .userCancelled, .pending:
            break

        @unknown default:
            break
        }
    }

    private func verifyOnBackend(transaction: Transaction, productId: String) async {
        let jwsToken = transaction.jwsRepresentation

        // 调用后端 tRPC 接口
        // await trpc.iap.verifyReceipt({ jwsToken, productId })
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw IAPError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum IAPError: Error {
    case failedVerification
}
```

### SwiftUI 充值页面

```swift
struct RechargeView: View {
    @StateObject private var iapManager = IAPManager()

    var body: some View {
        List(iapManager.products) { product in
            HStack {
                VStack(alignment: .leading) {
                    Text(product.displayName).font(.headline)
                    Text("获得 \(pointsLabel(for: product.id)) 积分")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(product.displayPrice) {
                    Task { try? await iapManager.purchase(product) }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .task { await iapManager.loadProducts() }
    }

    private func pointsLabel(for productId: String) -> String {
        switch productId {
        case "com.ainft.points.10":  return "10,000,000"
        case "com.ainft.points.50":  return "50,000,000"
        case "com.ainft.points.100": return "100,000,000"
        default: return "0"
        }
    }
}
```

---

## 安全设计

| 风险 | 防护措施 |
|---|---|
| 重放攻击（同一交易重复提交） | `RechargeModel.existsByTxHash(transactionId)` 前置检查，`tx_hash` 有索引 |
| 伪造 JWS Token | `SignedDataVerifier` 验证 Apple Root CA 签名链，伪造 JWS 无法通过 |
| JWS 字段与客户端不一致 | 后端从 JWS Payload 独立解码 bundleId / productId，不信任客户端上报 |
| 沙盒 Token 进入生产 | `payload.environment` 字段自动区分 |
| 过期证书链的 JWS 重放 | `enableOnlineChecks=true` 时使用当前时间校验证书有效期及 OCSP 吊销状态，过期证书签发的 JWS 无法通过 |

---

## 数据库迁移

IAP 复用现有 `t_recharge_records` 表，**无需新增表或迁移**。

仅需确认 `RechargeInsert` 类型的 `chain` 字段已扩展为支持 `'apple-iap'`：

```typescript
// packages/database/src/models/recharge.ts
export type RechargeInsert = {
  // ...
  chain: 'tron' | 'apple-iap';  // 新增 'apple-iap'
  // ...
};
```

---
