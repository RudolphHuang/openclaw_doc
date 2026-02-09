# OpenClaw 接入 AINFT 保姆级使用教程

---

OpenClaw（曾用名 **ClawdBot** 或 **Moltbot**）是一个开源的个人 AI 助理项目。它并非运行在云端的 SaaS 服务，而是部署在你自己的计算机上，让你能够**完全掌控自己的数据与工作流**。通过 WhatsApp、Telegram、飞书、钉钉等日常聊天工具，你就可以与它交互，让它处理邮件、管理日历、编写代码，甚至控制你的智能家居。

这个项目的核心理念在于，它不仅仅是一个能对话的聊天机器人，更是一个能**实际执行任务的「行动者」**。它拥有持久的记忆，可以访问你的文件系统和网络，并通过不断学习和扩展「技能」（Skills）来变得更强大。

由于其开源和可本地部署的特性，OpenClaw 吸引了大量开发者和技术爱好者，社区中涌现出许多富有创造力的用法，从自动化公司运营到管理个人生活，展现了个人 AI 助理的巨大潜力。

> 本篇教程将从零开始，详细介绍如何下载、安装并开始使用 OpenClaw，接入 AINFT 平台 API，帮助你搭建属于自己的第一个 AI 助理。

---

## 目录

- [申请 API Key](#申请-api-key)
- [安装前的准备](#安装前的准备)
- [开始安装 OpenClaw](#开始安装-openclaw)
- [初始化与配置](#初始化与配置)

---

## 申请 API Key

1. 登录 [AINFT 聊天平台](https://chat.ainft.com/)
2. 在 [API Key 管理页面](https://chat.ainft.com/key) 申请你的 `api_key`

![ainft_key.png](imgs/ainft_key.png)

---

## 安装前的准备

在开始安装之前，需要确保你的系统满足以下基本要求。OpenClaw 主要为类 Unix 环境设计，但在 Windows 上可以通过 **WSL2**（Windows Subsystem for Linux 2）完美运行。

### 系统要求

| 项目       | 要求说明 |
| ---------- | -------- |
| **Node.js** | 版本 ≥ 22，作为 OpenClaw 的运行环境 |
| **操作系统** | macOS、Linux，或 Windows（通过 WSL2） |
| **包管理器** | 从源码编译需安装 pnpm；推荐使用随 Node.js 安装的 npm |

确认环境最简单的方式是打开终端，输入以下命令检查 Node.js 版本：

```bash
node -v
```

---

## 开始安装 OpenClaw

OpenClaw 提供了多种安装方式，以适应不同用户的需求。对于初学者，**官方推荐使用一键安装脚本**，它能自动处理大部分环境配置。

### 快速安装（推荐）

这是最简单、最快捷的安装方式，会自动检测你的操作系统，安装必要依赖，并将 `openclaw` 命令部署到全局。

在 **macOS** 或 **Linux** 终端中执行：

```bash
curl -fsSL https://openclaw.bot/install.sh | bash
```

---

## 初始化与配置

等待几分钟后会出现 **Onboarding 向导**：

![onboarding0.png](imgs%2Fonboarding0.png)
向导会询问你以下关键信息：

- **AI 模型配置**：需要提供大语言模型服务的 API Key（如 Anthropic Claude、OpenAI GPT 或其它兼容服务）。  
  → 这一步先选择 **Skip for now** 跳过，后面再手动配置。
![onboarding1.png](imgs%2Fonboarding1.png)

- **通信渠道**：设置希望通过哪个聊天软件与 OpenClaw 交流（如 Telegram、WhatsApp）。目前多为国外软件，可先跳过，后续可参考集成飞书、钉钉等软件的教程。

- **Skills**：建议无脑选 **Yes**（先按空格键再按 Enter），或直接跳过。  
![onboarding2.png](imgs%2Fonboarding2.png)

完成后会启动 UI 界面，在浏览器中访问并进行对话即可。

## 编辑配置文件
### 打开配置文件
配置文件位于 ~/.openclaw/openclaw.json，OpenClaw 启动时会自动读取。
```bash
# 您也可以使用其他编辑器，如vim。
# vim ~/.openclaw/openclaw.json
nano ~/.openclaw/openclaw.json
```
### 添加AINFT 提供商配置
复制并粘贴以下配置内容models相关区域，将{AINFT_API_KEY}替换为刚才申请的AINFT API Key：
```json
{
  "models": {
    "mode": "merge",
    "providers": {
      "ainft": {
        "baseUrl": "https://chat.ainft.com/webapi/",
        "apiKey": "{AINFT_API_KEY}",
        "api": "openai-completions",
        "models": [
          {
            "id": "gpt-5-nano",
            "name": "gpt-5-nano"
          },
          {
            "id": "gpt-5-mini",
            "name": "gpt-5-mini"
          },
          {
            "id": "qwen/qwen3-30b-a3b",
            "name": "qwen/qwen3-30b-a3b"
          },
          {
            "id": "gemini-3-flash-preview",
            "name": "gemini-3-flash-preview"
          },
          {
            "id": "claude-haiku-4-5-20251001",
            "name": "claude-haiku-4-5-20251001"
          }
        ]
      }
    }
  }
}
```
### 设置gpt-5-nano为默认模型
在 openclaw.json 文件的 agents一节中参考如下设置ainft/gpt-5-nano为当前默认模型
```json
{
    "agents": {
        "defaults": {
            "model": {
                "primary": "ainft/gpt-5-nano"
            }
        }
    }
}
```
### 使用命令重启openclaw
```bash
openclaw gateway restart
```

### 尝试调用模型
```bash
openclaw agent --agent main --message "你好"
```
