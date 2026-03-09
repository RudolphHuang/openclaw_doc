#!/bin/bash
set -euo pipefail

# OpenClaw AINFT Provider 安装脚本
# 支持 Linux 和 macOS

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
AINFT_MODELS_API="https://chat.ainft.com/v1/models"

# 存储获取到的模型列表
AVAILABLE_MODELS=""
DEFAULT_MODEL=""

# 检测操作系统
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "Linux";;
        Darwin*)    echo "macOS";;
        CYGWIN*)    echo "Windows";;
        MINGW*)     echo "Windows";;
        MSYS*)      echo "Windows";;
        *)          echo "Unknown";;
    esac
}

OS=$(detect_os)

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
        print_info "请前往 https://nodejs.org/ 安装 Node.js >= 22"
        return 1
    fi
    
    node_version=$(node -v | sed 's/v//')
    major_version=$(echo "$node_version" | cut -d. -f1)
    
    if [ "$major_version" -lt 22 ]; then
        print_error "Node.js 版本需要 >= 22，当前版本: $node_version"
        print_info "请升级 Node.js: https://nodejs.org/"
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
        print_warn "jq 未安装，将使用内置方式处理 JSON"
        return 1
    fi
    print_success "jq 已安装"
    return 0
}

# 检查 curl 是否安装
check_curl() {
    if ! check_command curl; then
        print_error "curl 未安装，请先安装 curl"
        if [ "$OS" = "macOS" ]; then
            print_info "macOS 用户可以使用: brew install curl"
        elif [ "$OS" = "Linux" ]; then
            print_info "Ubuntu/Debian: sudo apt-get install curl"
            print_info "CentOS/RHEL: sudo yum install curl"
        fi
        return 1
    fi
    return 0
}

# 环境检查
check_environment() {
    print_bold "\n=== 检查系统环境 ==="
    print_info "检测到操作系统: $OS"
    
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
    
    # 检查 curl
    if ! check_curl; then
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
        # 在 macOS 和 Linux 上都兼容的方式读取输入
        if [ -t 0 ]; then
            # 交互式终端
            printf "请输入您的 AINFT API Key: "
            read -r api_key
        else
            # 非交互式（管道输入）
            read -r api_key
        fi
        
        if [ -z "$api_key" ]; then
            print_error "API Key 不能为空"
            continue
        fi
        
        # 简单的格式检查
        if [[ ! "$api_key" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            print_warn "API Key 格式看起来不太常见，请确认是否正确"
            printf "是否继续使用此 API Key? (y/N): "
            read -r confirm
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                continue
            fi
        fi
        
        break
    done
    
    AINFT_API_KEY="$api_key"
    print_success "API Key 已接收"
}

# 从 API 获取模型列表
fetch_models_from_api() {
    local api_key="$1"
    local response
    local http_code
    local body
    
    print_info "正在从 AINFT API 获取可用模型列表..."
    
    # 使用 curl 获取模型列表
    response=$(curl -s -w "\n%{http_code}" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${api_key}" \
        "${AINFT_MODELS_API}" 2>/dev/null || echo -e "\n000")
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" != "200" ]; then
        print_error "获取模型列表失败 (HTTP $http_code)"
        print_info "请检查您的 API Key 是否正确"
        if [ "$http_code" = "401" ]; then
            print_info "提示: HTTP 401 表示认证失败，请检查 API Key 是否有效"
        elif [ "$http_code" = "000" ]; then
            print_info "提示: 无法连接到服务器，请检查网络连接"
        fi
        return 1
    fi
    
    # 检查响应是否包含有效的模型数据
    if check_jq; then
        if ! echo "$body" | jq -e '.data' &>/dev/null; then
            print_error "API 返回数据格式异常"
            return 1
        fi
        # 提取模型 ID 列表
        AVAILABLE_MODELS=$(echo "$body" | jq -r '.data[].id' 2>/dev/null)
    else
        # 使用 grep/sed 作为备选方案
        AVAILABLE_MODELS=$(echo "$body" | grep -o '"id": "[^"]*"' | sed 's/"id": "//;s/"$//')
    fi
    
    if [ -z "$AVAILABLE_MODELS" ]; then
        print_error "未获取到任何模型"
        return 1
    fi
    
    local model_count
    model_count=$(echo "$AVAILABLE_MODELS" | wc -l | tr -d ' ')
    print_success "成功获取 $model_count 个模型"
    return 0
}

# 选择默认模型
select_default_model() {
    print_bold "\n=== 选择默认模型 ==="
    
    # 将模型列表转换为数组
    local models_array=()
    while IFS= read -r model; do
        models_array+=("$model")
    done <<< "$AVAILABLE_MODELS"
    
    # 显示可用模型
    print_info "可用模型列表:"
    local i=1
    for model in "${models_array[@]}"; do
        echo "  $i) $model"
        ((i++))
    done
    
    # 推荐优先级：gpt-5-nano > gpt-5-mini > 第一个可用模型
    local recommended=""
    if echo "$AVAILABLE_MODELS" | grep -q "^gpt-5-nano$"; then
        recommended="gpt-5-nano"
    elif echo "$AVAILABLE_MODELS" | grep -q "^gpt-5-mini$"; then
        recommended="gpt-5-mini"
    else
        recommended="${models_array[0]}"
    fi
    
    echo ""
    print_info "推荐默认模型: $recommended"
    
    # 询问用户是否使用推荐模型
    local use_recommended
    printf "是否使用推荐模型作为默认? (Y/n): "
    read -r use_recommended
    
    if [[ ! "$use_recommended" =~ ^[Nn]$ ]]; then
        DEFAULT_MODEL="$recommended"
    else
        # 让用户手动选择
        while true; do
            local selection
            printf "请输入模型编号 (1-${#models_array[@]}): "
            read -r selection
            
            if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#models_array[@]}" ]; then
                DEFAULT_MODEL="${models_array[$((selection-1))]}"
                break
            else
                print_error "无效的选择，请重新输入"
            fi
        done
    fi
    
    print_success "默认模型设置为: $DEFAULT_MODEL"
}

# 将模型列表转换为 JSON 格式
models_to_json() {
    local models="$1"
    local json_array=""
    
    while IFS= read -r model; do
        if [ -n "$json_array" ]; then
            json_array="${json_array},"
        fi
        json_array="${json_array}{\"id\": \"${model}\", \"name\": \"${model}\"}"
    done <<< "$models"
    
    echo "[$json_array]"
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
    
    # 将模型列表转换为 JSON 数组
    local models_json
    models_json=$(models_to_json "$AVAILABLE_MODELS")
    
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
        "models": ${models_json}
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "ainft/${DEFAULT_MODEL}"
      }
    }
  }
}
EOF
)
    
    # 合并配置
    local merged_config
    merged_config=$(echo "$config" | jq --argjson ainft "$ainft_config" --arg default_model "ainft/${DEFAULT_MODEL}" '
        .models.mode = "merge" |
        .models.providers.ainft = $ainft.models.providers.ainft |
        .agents.defaults.model.primary = $default_model
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
    
    # 构建模型列表 JSON
    local models_json=""
    local first=true
    while IFS= read -r model; do
        if [ "$first" = true ]; then
            first=false
        else
            models_json="${models_json},"
        fi
        models_json="${models_json}
          {\"id\": \"${model}\", \"name\": \"${model}\"}"
    done <<< "$AVAILABLE_MODELS"
    
    # 写入新配置
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
${models_json}
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "ainft/${DEFAULT_MODEL}"
      }
    }
  }
}
EOF
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

# 显示可用模型列表
print_available_models() {
    print_info "已配置的模型:"
    while IFS= read -r model; do
        if [ "$model" = "$DEFAULT_MODEL" ]; then
            echo "  - ainft/$model (默认)"
        else
            echo "  - ainft/$model"
        fi
    done <<< "$AVAILABLE_MODELS"
}

# 主函数
main() {
    echo -e "${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║          OpenClaw AINFT Provider 安装脚本                    ║"
    echo "║          支持 Linux / macOS                                  ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # 检查环境
    check_environment
    
    # 询问 API Key
    ask_api_key
    
    # 从 API 获取模型列表
    if ! fetch_models_from_api "$AINFT_API_KEY"; then
        print_error "无法获取模型列表，配置中止"
        exit 1
    fi
    
    # 选择默认模型
    select_default_model
    
    # 更新配置
    update_config
    
    # 重启 Gateway
    restart_gateway
    
    # 验证配置
    verify_config
    
    print_bold "\n=== 安装完成 ==="
    print_success "AINFT Provider 配置成功！"
    echo ""
    print_info "默认模型: ainft/$DEFAULT_MODEL"
    print_info "配置文件: $OPENCLAW_CONFIG_FILE"
    echo ""
    print_available_models
    echo ""
    print_info "如需切换模型，请编辑 ~/.openclaw/openclaw.json"
    print_info "或使用命令: openclaw models set ainft/<model-name>"
}

# 运行主函数
main "$@"
