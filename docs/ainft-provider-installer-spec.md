# AINFT Provider 一键安装脚本技术方案

## 1. 系统概述

### 1.1 背景
AINFT Provider 是 OpenClaw 的模型提供商之一，为用户提供便捷的 AI 模型接入能力。为降低用户配置门槛，提供跨平台一键安装脚本，自动完成从环境检查到配置生效的全流程。

### 1.2 目标平台
| 平台 | 脚本类型 | 执行方式 |
|------|----------|----------|
| Linux | Bash | `curl ... \| bash` |
| macOS | Bash | `curl ... \| bash` |
| Windows | PowerShell | `iwr ... \| iex` |

---

## 2. 系统架构

### 2.1 整体架构图

```mermaid
graph TB
    subgraph "用户终端"
        A[用户执行安装命令]
    end

    subgraph "安装脚本层"
        B[环境检查模块]
        C[API Key 交互模块]
        D[模型获取模块]
        E[配置更新模块]
        F[Gateway 控制模块]
    end

    subgraph "OpenClaw 本地环境"
        G[Node.js 运行时]
        H[OpenClaw CLI]
        I[配置文件目录<br/>~/.openclaw/]
        J[Gateway 服务]
    end

    subgraph "AINFT 云服务"
        K[AINFT API 服务<br/>chat.ainft.com]
        L[模型列表接口<br/>/v1/models]
        M[API Key 验证服务]
    end

    A --> B
    B --> G
    B --> H
    B --> I
    C --> M
    D --> L
    E --> I
    F --> J
    K --> L
    K --> M
```

### 2.2 模块职责

| 模块 | 职责 | 依赖 |
|------|------|------|
| 环境检查 | 验证 Node.js 版本、OpenClaw 安装状态、配置目录 | 本地命令行工具 |
| API Key 交互 | 接收并校验用户输入的 API Key 格式 | 用户输入 |
| 模型获取 | 调用 AINFT API 获取可用模型列表 | API Key、网络连接 |
| 配置更新 | 更新 openclaw.json 配置文件，自动备份 | 文件系统权限 |
| Gateway 控制 | 重启 Gateway 使配置生效 | OpenClaw CLI |

---

## 3. 安装流程

### 3.1 主流程图

```mermaid
flowchart TD
    Start([开始安装]) --> Init[初始化脚本<br/>检测系统语言]
    Init --> CheckEnv{环境检查}

    CheckEnv -->|Node.js < 22| Error1[提示升级 Node.js] --> End1([结束])
    CheckEnv -->|未安装 OpenClaw| Error2[提示安装 OpenClaw] --> End1
    CheckEnv -->|配置目录不存在| Error3[提示运行 onboard] --> End1
    CheckEnv -->|检查通过| InputKey[交互式输入 API Key]

    InputKey --> ValidateKey{格式校验}
    ValidateKey -->|格式异常| Confirm{用户确认}
    Confirm -->|重新输入| InputKey
    Confirm -->|继续使用| FetchModels[调用 AINFT API<br/>获取模型列表]
    ValidateKey -->|格式正常| FetchModels

    FetchModels -->|HTTP 401| Error4[提示 API Key 无效] --> End1
    FetchModels -->|网络错误| Error5[提示检查网络] --> End1
    FetchModels -->|获取成功| SelectModel[交互式选择默认模型]

    SelectModel -->|推荐| Rec[gpt-5-nano<br/>gpt-5-mini<br/>第一个可用]
    SelectModel -->|手动| Manual[用户输入模型编号]

    Rec --> UpdateConfig[更新配置文件]
    Manual --> UpdateConfig

    UpdateConfig --> Backup[自动备份原配置<br/>时间戳命名]
    Backup --> Write[写入新配置<br/>AINFT Provider 信息]

    Write --> Restart[重启 OpenClaw Gateway]
    Restart --> Verify[验证 Gateway 状态]
    Verify --> Show[展示配置结果<br/>可用模型列表]
    Show --> End2([安装完成])
```

### 3.2 环境检查详细流程

```mermaid
flowchart LR
    A[环境检查] --> B[Node.js 版本]
    A --> C[OpenClaw 安装]
    A --> D[配置目录]
    A --> E[依赖工具]

    B -->|≥22| B1[通过]
    B -->|<22| B2[失败提示]

    C -->|已安装| C1[通过]
    C -->|未安装| C2[失败提示]

    D -->|存在| D1[通过]
    D -->|不存在| D2[失败提示]

    E -->|curl/jq| E1[通过]
    E -->|缺失| E2[警告/降级]

    B1 --> F{全部通过?}
    C1 --> F
    D1 --> F
    E1 --> F
    E2 --> F

    F -->|是| G[继续安装]
    F -->|否| H[终止安装]
```

---

## 4. 配置更新时序

### 4.1 配置更新时序图

```mermaid
sequenceDiagram
    autonumber
    participant U as 用户
    participant S as 安装脚本
    participant FS as 文件系统
    participant A as AINFT API
    participant OC as OpenClaw

    U->>S: 执行安装脚本
    S->>FS: 检查 ~/.openclaw/ 目录
    FS-->>S: 目录状态

    S->>U: 提示输入 API Key
    U-->>S: 输入 API Key

    S->>A: GET /v1/models
    Note right of S: Authorization: Bearer {api_key}
    A-->>S: 模型列表响应

    S->>U: 展示可用模型
    U-->>S: 选择默认模型

    alt 配置文件存在
        S->>FS: 读取 openclaw.json
        FS-->>S: 现有配置
        S->>FS: 创建备份<br/>openclaw.json.backup.{timestamp}
    else 配置文件不存在
        S->>S: 初始化空配置
    end

    S->>S: 合并配置
    Note right of S: models.providers.ainft<br/>agents.defaults.model.primary

    S->>FS: 写入更新后的配置
    FS-->>S: 写入成功

    S->>OC: openclaw gateway restart
    OC-->>S: 重启结果

    S->>OC: openclaw gateway status
    OC-->>S: 运行状态

    S->>U: 展示安装结果<br/>测试命令提示
```

---

## 5. 配置结构

### 5.1 OpenClaw 配置模型

```mermaid
classDiagram
    class OpenClawConfig {
        +ModelsConfig models
        +AgentsConfig agents
    }

    class ModelsConfig {
        +string mode
        +Providers providers
    }

    class Providers {
        +Provider ainft
    }

    class Provider {
        +string baseUrl
        +string apiKey
        +string api
        +Model[] models
    }

    class Model {
        +string id
        +string name
    }

    class AgentsConfig {
        +Defaults defaults
    }

    class Defaults {
        +ModelConfig model
    }

    class ModelConfig {
        +string primary
    }

    OpenClawConfig --> ModelsConfig
    OpenClawConfig --> AgentsConfig
    ModelsConfig --> Providers
    Providers --> Provider
    Provider --> Model
    AgentsConfig --> Defaults
    Defaults --> ModelConfig
```

### 5.2 配置合并策略

```mermaid
graph LR
    A[现有配置] --> C[配置合并]
    B[AINFT 配置] --> C
    C --> D[合并后配置]

    subgraph 合并规则
        R1["models.mode = merge"]
        R2["models.providers.ainft = 新配置"]
        R3["agents.defaults.model.primary = ainft/默认模型"]
    end

    C -.-> R1
    C -.-> R2
    C -.-> R3
```

---

## 6. 多语言支持架构

### 6.1 语言检测与消息系统

```mermaid
graph TD
    A[脚本启动] --> B{检测系统语言}

    B -->|Linux/macOS| C[读取 LANG<br/>LC_ALL<br/>LC_MESSAGES]
    B -->|Windows| D[读取 CurrentUICulture]

    C --> E{是否中文?}
    D --> E

    E -->|是| F[使用中文消息]
    E -->|否| G[使用英文消息]

    F --> H[消息字典查找]
    G --> H

    H --> I[输出本地化消息]

    subgraph "消息键值结构"
        J[INFO_PREFIX] --> J1["[INFO]|[INFO]"]
        K[NODE_VERSION_OK] --> K1["Node.js 版本检查通过|Node.js version check passed"]
        L[API_KEY_PROMPT] --> L1["请前往...申请 API Key|Please visit..."]
    end

    H -.-> J
    H -.-> K
    H -.-> L
```

---

## 7. 错误处理架构

### 7.1 错误分类与处理

```mermaid
graph TD
    A[错误类型] --> B[环境错误]
    A --> C[网络错误]
    A --> D[认证错误]
    A --> E[配置错误]

    B --> B1[Node.js 版本过低]
    B --> B2[OpenClaw 未安装]
    B --> B3[配置目录缺失]

    C --> C1[HTTP 000<br/>网络不可达]
    C --> C2[HTTP 5xx<br/>服务端错误]

    D --> D1[HTTP 401<br/>API Key 无效]

    E --> E1[配置文件权限不足]
    E --> E2[JSON 解析失败]

    B1 --> F[提示升级并退出]
    B2 --> F
    B3 --> F

    C1 --> G[提示检查网络并退出]
    C2 --> G

    D1 --> H[提示检查 API Key<br/>并退出]

    E1 --> I[提示检查权限<br/>并退出]
    E2 --> J[降级到 sed 处理]
```

---

## 8. 部署与分发

### 8.1 脚本分发架构

```mermaid
graph TB
    subgraph "源码仓库"
        A[scripts/install-ainft-provider.sh]
        B[scripts/install-ainft-provider.ps1]
    end

    subgraph "CDN 分发"
        C[chat.ainft.com/scripts/openclaw/]
        C --> D[install-ainft-provider.sh]
        C --> E[install-ainft-provider.ps1]
    end

    subgraph "用户执行"
        F[Linux/macOS 用户]
        G[Windows 用户]

        F -->|curl \| bash| D
        G -->|iwr \| iex| E
    end

    A -.->|部署| C
    B -.->|部署| C
```

---

## 9. 安全考虑

### 9.1 安全措施

| 措施 | 说明 |
|------|------|
| API Key 格式校验 | 正则匹配 `^[a-zA-Z0-9_-]+$`，异常时二次确认 |
| 配置文件备份 | 自动创建时间戳备份，防止配置丢失 |
| 权限检查 | 依赖系统文件权限保护配置安全 |
| 错误信息脱敏 | 日志中不输出完整 API Key |

---

## 10. 验证与测试

### 10.1 验证流程

```mermaid
graph LR
    A[安装完成] --> B[Gateway 状态检查]
    B -->|运行中| C[配置验证通过]
    B -->|未运行| D[提示手动重启]

    C --> E[输出测试命令]
    E --> F["openclaw agent --agent main --message '你好'"]

    F --> G{测试执行}
    G -->|正常返回| H[安装成功]
    G -->|异常返回| I[检查配置]
```

---

## 附录：模型推荐策略

```mermaid
graph TD
    A[获取模型列表] --> B{列表中包含?}

    B -->|gpt-5-nano| C[推荐 gpt-5-nano]
    B -->|无 nano<br/>有 mini| D[推荐 gpt-5-mini]
    B -->|均无| E[推荐第一个可用模型]

    C --> F[询问用户使用推荐?]
    D --> F
    E --> F

    F -->|是| G[设为默认模型]
    F -->|否| H[手动输入模型编号]
    H --> G
```
