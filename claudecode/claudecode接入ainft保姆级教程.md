# Claude Code 接入 AiNFT 保姆级教程

本文档详细介绍如何将 Claude Code CLI 工具配置为使用 AiNFT API 进行代理调用。

## 环境变量配置

在使用 Claude Code 之前，需要设置以下环境变量：

```bash
export ANTHROPIC_BASE_URL=https://api.ainft.com/
export ANTHROPIC_AUTH_TOKEN=""
export ANTHROPIC_MODEL=gpt-5-nano
```

### 变量说明

| 变量名 | 说明 | 示例值 |
|--------|------|--------|
| `ANTHROPIC_BASE_URL` | AiNFT API 的代理地址 | `https://api.ainft.com/` |
| `ANTHROPIC_AUTH_TOKEN` | 你的 AiNFT API Token | `sk-...` |
| `ANTHROPIC_MODEL` | 使用的模型名称 | `gpt-5-nano` |

### 持久化配置

#### Bash 用户

将上述 `export` 命令添加到 `~/.bashrc`：

```bash
echo 'export # Claude CLI - Use AiNFT' >> ~/.bashrc
echo 'export ANTHROPIC_BASE_URL=https://api.ainft.com/' >> ~/.bashrc
echo 'export ANTHROPIC_AUTH_TOKEN="sk-..."' >> ~/.bashrc
echo 'export ANTHROPIC_MODEL=gpt-5-nano' >> ~/.bashrc
source ~/.bashrc
```

#### Zsh 用户

将上述 `export` 命令添加到 `~/.zshrc`：

```bash
echo 'export # Claude CLI - Use AiNFT' >> ~/.zshrc
echo 'export ANTHROPIC_BASE_URL=https://api.ainft.com/' >> ~/.zshrc
echo 'export ANTHROPIC_AUTH_TOKEN="sk-..."' >> ~/.zshrc
echo 'export ANTHROPIC_MODEL=gpt-5-nano' >> ~/.zshrc
source ~/.zshrc
```

## 验证配置

设置完成后，启动 Claude Code 验证配置是否生效：

```bash
claude
```

如果配置正确，Claude Code 将使用 AiNFT 提供的 API 进行对话。

## 注意事项

1. **Token 安全**：`ANTHROPIC_AUTH_TOKEN` 是你的私密凭证
2. **网络环境**：确保能够访问 `api.ainft.com` 域名
3. **模型选择**：根据实际需求选择合适的模型，不同模型可能有不同的能力和限制
