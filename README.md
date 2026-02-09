OpenClaw接入AINFT保姆级使用教程



OpenClaw，曾用名 ClawdBot 或 Moltbot，是一个开源的个人 AI 助理项目。它并非运行在云端的 SaaS 服务，而是部署在你自己的计算机上，让你能够完全掌控自己的数据与工作流。通过 WhatsApp、Telegram、飞书、钉钉等日常聊天工具，你就可以与它交互，让它处理邮件、管理日历、编写代码，甚至控制你的智能家居。

这个项目的核心理念在于，它不仅仅是一个能对话的聊天机器人，更是一个能实际执行任务的“行动者”。它拥有持久的记忆，可以访问你的文件系统和网络，并通过不断学习和扩展“技能”（Skills）来变得更强大。
由于其开源和可本地部署的特性，OpenClaw 吸引了大量开发者和技术爱好者，社区中涌现出许多富有创造力的用法，从自动化公司运营到管理个人生活，展现了个人 AI 助理的巨大潜力。

本篇教程将从零开始，详细介绍如何下载、安装并开始使用 OpenClaw，接入AINFT平台API，帮助你搭建属于自己的第一个 AI 助理。




第一步：申请api

登录https://chat.ainft.com/
在https://chat.ainft.com/key 页面中申请api_key

![ainft_key.png](imgs%2Fainft_key.png)

安装前的准备
在开始安装之前，需要确保你的系统满足以下基本要求。OpenClaw 主要为类 Unix 环境设计，但在 Windows 上可以通过 WSL2 (Windows Subsystem for Linux 2) 完美运行。

系统要求:
Node.js: 版本需要大于或等于 22。Node.js 是 OpenClaw 的运行环境。
操作系统: macOS, Linux, 或 Windows (通过 WSL2)。
包管理器: 如果选择从源码编译，需要安装 pnpm。对于大多数用户，推荐使用 npm，它会随 Node.js 一起安装。



确认环境最简单的方式是打开你的终端（Terminal）并输入以下命令检查 Node.js 版本：

```bash
node -v
```

开始安装 OpenClaw
OpenClaw 提供了多种安装方式，以适应不同用户的需求。对于初学者，官方推荐使用一键安装脚本，它能自动处理大部分环境配置。



快速安装 (推荐)
这是最简单、最快捷的安装方式。它会自动检测你的操作系统，安装必要的依赖，并将 openclaw 命令部署到全局。



对于 macOS 或 Linux 系统，请在终端中执行以下命令：

```bash
curl -fsSL https://openclaw.bot/install.sh | bash
```
