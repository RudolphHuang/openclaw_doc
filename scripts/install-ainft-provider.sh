#!/bin/bash
set -euo pipefail

# OpenClaw AINFT Provider 安装脚本
# 用于自动配置 AINFT 作为 OpenClaw 的模型提供商

# 颜色定义
BOLD='\033[1m'
INFO='\033[38;2;136;146;176m'
SUCCESS='\033[38;2;0;229;204m'
WARN='\033[38;2;255;176;32m'
ERROR='\033[38;2;230;57;70m'
NC='\033[0m'

# 配置路径
OPENCLAW_CONFIG_DIR="${HOME}/.openclaw"
OPENCLAW_CONFIG_FILE="${OPENCLAW_CONFIG_DIR}/openclaw.json"

# AINFT Provider 配置
AINFT_BASE_URL="https://chat.ainft.com/webapi/"
AINFT_API="openai-completions"

# 打印带颜色的消息
print_info() {
    echo -e "${INFO}[INFO]${NC} $1"
}

print_success() {
    echo -e "${SUCCESS}[SUCCESS]${NC} $1"
}

print_warn() {
    echo -e "${WARN}[WARN]${NC} $1"
}

print_error() {
    echo -e "${ERROR}[ERROR]${NC} $1"
}

print_bold() {
    echo -e "${BOLD}$1${NC}"
}

# 检查命令是否存在
check_command() {
    if ! command -v "$1" &> /dev/null; then
        return 1
    fi
    return 0
}

# 检查 Node.js 版本
check_node_version() {
    local node_version
    local major_version
    
    if ! check_command node; then
        print_error "Node.js 未安装"
        return 1
    fi
    
    node_version=$(node -v | sed 's/v//')
    major_version=$(echo "$node_version" | cut -d. -f1)
    
    if [ "$major_version" -lt 22 ]; then
        print_error "Node.js 版本需要 >= 22，当前版本: $node_version"
        return 1
    fi
    
    print_success "Node.js 版本检查通过: v$node_version"
    return 0
}

# 检查 openclaw 是否已安装
check_openclaw_installed() {
    if ! check_command openclaw; then
        print_error "openclaw 命令未找到"
        print_info "请先安装 OpenClaw:"
        print_info "  curl -fsSL https://openclaw.bot/install.sh | bash"
        return 1
    fi
    
    local version
    version=$(openclaw --version 2>/dev/null || echo "unknown")
    print_success "OpenClaw 已安装: $version"
    return 0
}

# 检查配置文件目录是否存在
check_config_dir() {
    if [ ! -d "$OPENCLAW_CONFIG_DIR" ]; then
        print_error "OpenClaw 配置目录不存在: $OPENCLAW_CONFIG_DIR"
        print_info "请先运行 'openclaw onboard' 完成初始化配置"
        return 1
    fi
    print_success "配置目录检查通过: $OPENCLAW_CONFIG_DIR"
    return 0
}

# 检查 jq 是否安装（用于处理 JSON）
check_jq() {
    if ! check_command jq; then
        print_warn "jq 未安装，将尝试使用 sed 进行配置修改"
        return 1
    fi
    print_success "jq 已安装"
    return 0
}

# 环境检查
check_environment() {
    print_bold "\n=== 检查系统环境 ==="
    
    local all_passed=true
    
    # 检查 Node.js
    if ! check_node_version; then
        all_passed=false
    fi
    
    # 检查 openclaw
    if ! check_openclaw_installed; then
        all_passed=false
    fi
    
    # 检查配置目录
    if ! check_config_dir; then
        all_passed=false
    fi
    
    if [ "$all_passed" = false ]; then
        print_error "环境检查未通过，请先完成 OpenClaw 的安装和初始化"
        exit 1
    fi
    
    print_success "环境检查全部通过"
}

# 询问用户输入 API Key
ask_api_key() {
    print_bold "\n=== 配置 AINFT API Key ==="
    print_info "请前往 https://chat.ainft.com/key 申请 API Key"
    echo ""
    
    local api_key
    while true; do
        read -rp "请输入您的 AINFT API Key: " api_key
        
        if [ -z "$api_key" ]; then
            print_error "API Key 不能为空"
            continue
        fi
        
        # 简单的格式检查（通常 API key 以 sk- 开头）
        if [[ ! "$api_key" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            print_warn "API Key 格式看起来不太常见，请确认是否正确"
            read -rp "是否继续使用此 API Key? (y/N): " confirm
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                continue
            fi
        fi
        
        break
    done
    
    AINFT_API_KEY="$api_key"
    print_success "API Key 已接收"
}

# 使用 jq 更新配置文件
update_config_with_jq() {
    local config_file="$1"
    local api_key="$2"
    
    # 读取现有配置或创建新的
    local config
    if [ -f "$config_file" ]; then
        config=$(cat "$config_file")
    else
        config="{}"
    fi
    
    # 创建 AINFT provider 配置
    local ainft_config
    ainft_config=$(cat <<EOF
{
  "models": {
    "mode": "merge",
    "providers": {
      "ainft": {
        "baseUrl": "${AINFT_BASE_URL}",
        "apiKey": "${api_key}",
        "api": "${AINFT_API}",
        "models": [
          {"id": "gpt-5-nano", "name": "gpt-5-nano"},
          {"id": "gpt-5-mini", "name": "gpt-5-mini"},
          {"id": "qwen/qwen3-30b-a3b", "name": "qwen/qwen3-30b-a3b"},
          {"id": "gemini-3-flash-preview", "name": "gemini-3-flash-preview"},
          {"id": "claude-haiku-4-5-20251001", "name": "claude-haiku-4-5-20251001"}
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "ainft/gpt-5-nano"
      }
    }
  }
}
EOF
)
    
    # 合并配置
    local merged_config
    merged_config=$(echo "$config" | jq --argjson ainft "$ainft_config" '
        .models.mode = "merge" |
        .models.providers.ainft = $ainft.models.providers.ainft |
        .agents.defaults.model.primary = "ainft/gpt-5-nano"
    ')
    
    # 写入文件
    echo "$merged_config" > "$config_file"
}

# 使用 sed 更新配置文件（备用方案）
update_config_with_sed() {
    local config_file="$1"
    local api_key="$2"
    
    # 如果文件不存在，创建基本结构
    if [ ! -f "$config_file" ]; then
        cat > "$config_file" <<EOF
{
  "models": {
    "mode": "merge",
    "providers": {}
  },
  "agents": {
    "defaults": {
      "model": {}
    }
  }
}
EOF
    fi
    
    # 备份原配置
    cp "$config_file" "${config_file}.backup.$(date +%Y%m%d%H%M%S)"
    
    # 创建临时文件存储 AINFT 配置
    local temp_file
    temp_file=$(mktemp)
    
    cat > "$temp_file" <<EOF
{
  "models": {
    "mode": "merge",
    "providers": {
      "ainft": {
        "baseUrl": "${AINFT_BASE_URL}",
        "apiKey": "${api_key}",
        "api": "${AINFT_API}",
        "models": [
          {"id": "gpt-5-nano", "name": "gpt-5-nano"},
          {"id": "gpt-5-mini", "name": "gpt-5-mini"},
          {"id": "qwen/qwen3-30b-a3b", "name": "qwen/qwen3-30b-a3b"},
          {"id": "gemini-3-flash-preview", "name": "gemini-3-flash-preview"},
          {"id": "claude-haiku-4-5-20251001", "name": "claude-haiku-4-5-20251001"}
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "ainft/gpt-5-nano"
      }
    }
  }
}
EOF
    
    # 使用简单的替换方式（这里我们直接覆盖，因为 sed 处理 JSON 比较复杂）
    cat > "$config_file" <<EOF
{
  "models": {
    "mode": "merge",
    "providers": {
      "ainft": {
        "baseUrl": "${AINFT_BASE_URL}",
        "apiKey": "${api_key}",
        "api": "${AINFT_API}",
        "models": [
          {"id": "gpt-5-nano", "name": "gpt-5-nano"},
          {"id": "gpt-5-mini", "name": "gpt-5-mini"},
          {"id": "qwen/qwen3-30b-a3b", "name": "qwen/qwen3-30b-a3b"},
          {"id": "gemini-3-flash-preview", "name": "gemini-3-flash-preview"},
          {"id": "claude-haiku-4-5-20251001", "name": "claude-haiku-4-5-20251001"}
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "ainft/gpt-5-nano"
      }
    }
  }
}
EOF
    
    rm -f "$temp_file"
}

# 更新配置文件
update_config() {
    print_bold "\n=== 更新 OpenClaw 配置文件 ==="
    
    # 备份原配置
    if [ -f "$OPENCLAW_CONFIG_FILE" ]; then
        local backup_file="${OPENCLAW_CONFIG_FILE}.backup.$(date +%Y%m%d%H%M%S)"
        cp "$OPENCLAW_CONFIG_FILE" "$backup_file"
        print_info "原配置已备份到: $backup_file"
    fi
    
    # 使用 jq 或 sed 更新配置
    if check_jq; then
        update_config_with_jq "$OPENCLAW_CONFIG_FILE" "$AINFT_API_KEY"
    else
        update_config_with_sed "$OPENCLAW_CONFIG_FILE" "$AINFT_API_KEY"
    fi
    
    print_success "配置文件已更新: $OPENCLAW_CONFIG_FILE"
}

# 重启 Gateway
restart_gateway() {
    print_bold "\n=== 重启 OpenClaw Gateway ==="
    
    if ! check_command openclaw; then
        print_error "openclaw 命令未找到，无法重启 Gateway"
        return 1
    fi
    
    print_info "正在重启 Gateway..."
    if openclaw gateway restart; then
        print_success "Gateway 重启成功"
    else
        print_error "Gateway 重启失败"
        print_info "您可以手动运行: openclaw gateway restart"
        return 1
    fi
}

# 验证配置
verify_config() {
    print_bold "\n=== 验证配置 ==="
    
    print_info "检查 Gateway 状态..."
    if openclaw gateway status &>/dev/null; then
        print_success "Gateway 运行正常"
    else
        print_warn "Gateway 状态检查失败，请手动检查"
    fi
    
    print_info "提示: 您可以运行以下命令测试模型:"
    print_info "  openclaw agent --agent main --message \"你好\""
}

# 主函数
main() {
    echo -e "${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║          OpenClaw AINFT Provider 安装脚本                    ║"
    echo "║          用于配置 AINFT 作为 OpenClaw 的模型提供商           ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # 检查环境
    check_environment
    
    # 询问 API Key
    ask_api_key
    
    # 更新配置
    update_config
    
    # 重启 Gateway
    restart_gateway
    
    # 验证配置
    verify_config
    
    print_bold "\n=== 安装完成 ==="
    print_success "AINFT Provider 配置成功！"
    print_info "默认模型已设置为: ainft/gpt-5-nano"
    print_info "配置文件位置: $OPENCLAW_CONFIG_FILE"
    echo ""
    print_info "可用模型:"
    print_info "  - ainft/gpt-5-nano"
    print_info "  - ainft/gpt-5-mini"
    print_info "  - ainft/qwen/qwen3-30b-a3b"
    print_info "  - ainft/gemini-3-flash-preview"
    print_info "  - ainft/claude-haiku-4-5-20251001"
    echo ""
    print_info "如需切换模型，请编辑 ~/.openclaw/openclaw.json"
    print_info "或使用命令: openclaw models set ainft/<model-name>"
}

# 运行主函数
main "$@"
