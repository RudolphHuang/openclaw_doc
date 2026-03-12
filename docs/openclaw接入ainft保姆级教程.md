# OpenClaw 接入 AINFT 保姆级教程

本文档详细介绍如何将 OpenClaw 工具配置为使用 AINFT API 进行代理调用。

---

## 目录

- [方式一：自动配置（推荐）](#方式一自动配置推荐)
  - [正式环境](#正式环境暂未发布)
  - [测试环境](#测试环境)
  - [自动配置流程](#自动配置流程)
- [方式二：手动配置](#方式二手动配置)
  - [1. 申请 API Key](#1-申请-api-key)
  - [2. 修改配置文件](#2-修改配置文件)
  - [3. 重启 Gateway](#3-重启-gateway)
- [兼容性测试](#兼容性测试)
- [常见问题](#常见问题)

---

## 方式一：自动配置（推荐）

使用一键安装脚本，自动完成环境检查、API Key 配置和模型选择。

### 正式环境（暂未发布）

**Linux & macOS:**

```bash
curl https://chat.ainft.com/scripts/openclaw-install-ainft-provider.sh | bash
```

**Windows PowerShell:**

```powershell
iwr https://chat.ainft.com/scripts/openclaw-install-ainft-provider.ps1 | iex
```

---

### 测试环境

**Linux & macOS:**

```bash
curl https://chat-dev.ainft.com/scripts/openclaw-install-ainft-provider.sh | bash
```

**Windows PowerShell:**

```powershell
iwr https://chat-dev.ainft.com/scripts/openclaw-install-ainft-provider.ps1 | iex
```

---

### 自动配置流程

脚本会自动执行以下步骤：

#### 1. 环境检查
- 检查 Node.js 版本（要求 22+）
- 检查 OpenClaw 是否已安装和初始化
- 检查网络连接

#### 2. 输入 API Key
根据提示输入从 AINFT 平台申请的 API Key：

![输入 API Key](img.png)

#### 3. 选择默认模型
验证 API Key 有效后，脚本会获取可用模型列表并让你选择默认模型：

![选择默认模型](img_1.png)

#### 4. 完成配置
选择完成后，脚本会自动：
- 备份原有配置
- 更新 OpenClaw 配置文件
- 重启 Gateway

![配置完成](img_2.png)

---

## 方式二：手动配置

如果自动配置脚本无法使用，或需要自定义配置，可以手动进行配置。

### 1. 申请 API Key

1. 登录 [AINFT 聊天平台](https://chat.ainft.com/)
2. 进入 [API Key 管理页面](https://chat.ainft.com/key)
3. 点击申请新的 API Key

![API Key 管理页面](../imgs/ainft_key.png)

---

### 2. 修改配置文件

编辑 OpenClaw 配置文件 `~/.openclaw/openclaw.json`：

```json
{
  "providers": {
    "ainft": {
      "baseUrl": "https://api.ainft.com",
      "apiKey": "your-api-key-here"
    }
  },
  "models": {
    "default": "ainft/gpt-5-nano",
    "available": [
      "ainft/gpt-5-nano",
      "ainft/gpt-5-mini",
      "ainft/gpt-5"
    ]
  }
}
```

**配置说明：**

| 配置项 | 说明 | 示例 |
|--------|------|------|
| `providers.ainft.baseUrl` | AINFT API 基础地址 | `https://api.ainft.com` |
| `providers.ainft.apiKey` | 你的 API Key | `ak-xxxxxxxx` |
| `models.default` | 默认使用的模型 | `ainft/gpt-5-nano` |
| `models.available` | 可用模型列表 | 根据你的套餐选择 |

---

### 3. 重启 Gateway

配置修改后，需要重启 OpenClaw Gateway 使配置生效：

```bash
# 停止 Gateway
openclaw gateway stop

# 启动 Gateway
openclaw gateway start
```

或者使用重启命令：

```bash
openclaw gateway restart
```

---

## 兼容性测试

| 操作系统             | 自动配置 | 手动配置 |
|------------------|---------|---------|
| Ubuntu 24.04     | ✅ 通过 | ✅ 通过 |
| Windows 11 25H2  | ✅ 通过 | ✅ 通过 |
| macOS 24.6.0     | ✅ 通过 | ✅ 通过 |

---

## 常见问题

**Q: 脚本执行失败怎么办？**

A: 请确保：
1. 已安装 Node.js 22 或更高版本
2. 已安装并初始化 OpenClaw（运行过 `openclaw onboard`）
3. 网络连接正常，可以访问 AINFT API

如果仍有问题，请尝试[手动配置](#方式二手动配置)。

---

**Q: 如何切换模型？**

A: 使用命令：
```bash
openclaw models set ainft/<模型名称>
```

或手动编辑 `~/.openclaw/openclaw.json` 配置文件。

---

**Q: 如何验证配置是否成功？**

A: 运行以下命令测试：
```bash
openclaw models list
```

如果能看到 AINFT 的模型列表，说明配置成功。

---

**Q: 配置文件路径在哪里？**

A: 不同操作系统的配置文件路径：

| 操作系统 | 配置文件路径 |
|---------|-------------|
| Linux/macOS | `~/.openclaw/openclaw.json` |
| Windows | `%USERPROFILE%\.openclaw\openclaw.json` |
