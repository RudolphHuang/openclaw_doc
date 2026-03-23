# Claude Code 接入 AINFT 保姆级教程

本文档详细介绍如何将 Claude Code 配置为使用 AINFT API 进行代理调用。

---

## 目录


- [方式二：手动配置](#方式二手动配置)
    - [1. 申请 API Token](#1-申请-api-token)
    - [2. 配置环境变量](#2-配置环境变量)
    - [3. 验证配置](#3-验证配置)
- [切换模型](#切换模型)
- [兼容性测试](#兼容性测试)
- [常见问题](#常见问题)

---


## 方式二：手动配置

如果自动配置脚本无法使用，或需要自定义配置，可以手动进行配置。

### 1. 申请 API Token

1. 登录 [AINFT 聊天平台](https://chat.ainft.com/)
2. 进入 [API Token 管理页面](https://chat.ainft.com/key)
3. 点击申请新的 API Token

![API Token 管理页面](../../imgs/ainft_key.png)

---

### 2. 配置环境变量

根据你的 Shell 类型，在对应的配置文件中添加环境变量。

#### Linux / macOS (Bash)

编辑 `~/.bashrc` 文件：

```bash
# Claude Code - AINFT Provider Configuration
export ANTHROPIC_BASE_URL="https://api.ainft.com/"
export ANTHROPIC_AUTH_TOKEN="your-api-token-here"
export ANTHROPIC_MODEL="gpt-5-nano"
# End of AINFT Provider Configuration
```

使配置生效：

```bash
source ~/.bashrc
```

---

#### Linux / macOS (Zsh)

编辑 `~/.zshrc` 文件：

```bash
# Claude Code - AINFT Provider Configuration
export ANTHROPIC_BASE_URL="https://api.ainft.com/"
export ANTHROPIC_AUTH_TOKEN="your-api-token-here"
export ANTHROPIC_MODEL="gpt-5-nano"
# End of AINFT Provider Configuration
```

使配置生效：

```bash
source ~/.zshrc
```

---

#### Windows (PowerShell)

编辑 PowerShell 配置文件：

```powershell
# Claude Code - AINFT Provider Configuration
$env:ANTHROPIC_BASE_URL = "https://api.ainft.com/"
$env:ANTHROPIC_AUTH_TOKEN = "your-api-token-here"
$env:ANTHROPIC_MODEL = "gpt-5-nano"
# End of AINFT Provider Configuration
```

使配置生效：

```powershell
. $PROFILE
```

**配置文件路径说明：**

| 操作系统 | Shell | 配置文件路径 |
|---------|-------|-------------|
| Linux | Bash | `~/.bashrc` |
| Linux | Zsh | `~/.zshrc` |
| macOS | Bash | `~/.bashrc` 或 `~/.bash_profile` |
| macOS | Zsh | `~/.zshrc` |
| Windows | PowerShell | `$PROFILE` |

---

### 3. 验证配置

运行以下命令验证配置是否成功：

```bash
claude --version
```

然后启动 Claude Code：

```bash
claude
```

如果能正常启动并看到 AINFT 的模型响应，说明配置成功。

---

## 切换模型

### 临时切换（单次会话）

**Linux / macOS:**

```bash
ANTHROPIC_MODEL=gpt-5-mini claude
```

**Windows PowerShell:**

```powershell
$env:ANTHROPIC_MODEL="gpt-5-mini"; claude
```

### 永久切换

修改配置文件中的 `ANTHROPIC_MODEL` 环境变量，然后重新加载配置。

---

## 兼容性测试

进行中
---

## 常见问题

**Q: 脚本执行失败怎么办？**

A: 请确保：
1. 已安装 Claude Code（运行过 `claude` 命令）
2. 已安装 curl（Linux/macOS）
3. 网络连接正常，可以访问 AINFT API

如果仍有问题，请尝试[手动配置](#方式二手动配置)。

---

**Q: 提示 "claude command not found" 怎么办？**

A: 请先安装 Claude Code：

**Linux & macOS:**
```bash
curl -fsSL https://claude.ai/install.sh | bash
```

**Windows PowerShell:**
```powershell
iwr -useb https://claude.ai/install.ps1 | iex
```

---

**Q: 如何验证配置是否成功？**

A: 运行以下命令检查环境变量：

**Linux / macOS:**
```bash
echo $ANTHROPIC_BASE_URL
echo $ANTHROPIC_MODEL
```

**Windows PowerShell:**
```powershell
$env:ANTHROPIC_BASE_URL
$env:ANTHROPIC_MODEL
```

---

**Q: 如何查看当前使用的模型？**

A: 启动 Claude Code 后，在对话中输入：

```
/info
```

或查看启动时的系统信息。


---

**Q: 如何卸载 AINFT Provider 配置？**

A: 编辑你的 Shell 配置文件，删除以下注释块之间的内容：

```bash
# Claude Code - AINFT Provider Configuration
...
# End of AINFT Provider Configuration
```

然后重新加载配置文件即可。
