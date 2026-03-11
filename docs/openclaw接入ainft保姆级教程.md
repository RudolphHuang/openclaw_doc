# openclaw 接入 AiNFT 保姆级教程

本文档详细介绍如何将 openclaw 工具配置为使用 AiNFT API 进行代理调用。

## 正式环境命令（暂未发布）

### Linux & macOS

```bash
curl https://api.ainft.com/scripts/openclaw/install-ainft-provider.sh | bash
```

### Windows PowerShell

```powershell
iwr https://api.ainft.com/scripts/openclaw/install-ainft-provider.ps1 | iex
```

## 测试阶段命令

### Linux & macOS

```bash
curl https://raw.githubusercontent.com/RudolphHuang/openclaw_doc/refs/heads/main/scripts/openclaw/install-ainft-provider.sh | bash
```

### Windows PowerShell

```powershell
iwr https://raw.githubusercontent.com/RudolphHuang/openclaw_doc/refs/heads/main/scripts/openclaw/install-ainft-provider.ps1 | iex
```

## 申请 API Key

1. 登录 [AINFT 聊天平台](https://chat.ainft.com/)
2. 在 [API Key 管理页面](https://chat.ainft.com/key) 申请你的 `api_key`

![ainft_key.png](../imgs/ainft_key.png)


输入完成后弹出对话框询问用户apikey

![img.png](img.png)

验证apikey有效后会让用户选择默认模型
![img_1.png](img_1.png)

选择完成后，会帮用户修改配置，备份旧的配置，并且重启
![img_2.png](img_2.png)

