#!/bin/bash
set -euo pipefail

# Claude Code AINFT Provider 安装脚本
# 支持 Linux 和 macOS

# 颜色定义
BOLD='\033[1m'
INFO='\033[38;2;136;146;176m'
SUCCESS='\033[38;2;0;229;204m'
WARN='\033[38;2;255;176;32m'
ERROR='\033[38;2;230;57;70m'
NC='\033[0m'

# AINFT Provider 配置
AINFT_BASE_URL="https://api.ainft.com/"
AINFT_MODELS_API="https://api.ainft.com/v1/models"

# 默认模型
DEFAULT_MODEL=""
AVAILABLE_MODELS=""

# 检测系统语言（中文环境返回 zh，其他返回 en）
detect_language() {
    local lang="${LANG:-}"
    local lc_all="${LC_ALL:-}"
    local lc_messages="${LC_MESSAGES:-}"

    # 优先检查 LC_ALL，然后是 LC_MESSAGES，最后是 LANG
    local check_lang="${lc_all:-${lc_messages:-${lang:-}}}"

    # 检查是否包含中文语言代码
    if [[ "$check_lang" =~ ^(zh|zh_CN|zh_TW|zh_HK|zh_SG) ]]; then
        echo "zh"
    else
        echo "en"
    fi
}

# 设置语言
LANG_CODE=$(detect_language)

# 多语言消息定义
# 格式: msg_key="zh_message|en_message"
declare -A MESSAGES

# 标题和通用
MESSAGES[TITLE]="Claude Code AINFT Provider 安装脚本|Claude Code AINFT Provider Installation Script"
MESSAGES[SUPPORT]="支持 Linux / macOS|Supports Linux / macOS"
MESSAGES[INFO_PREFIX]="[INFO]|[INFO]"
MESSAGES[SUCCESS_PREFIX]="[SUCCESS]|[SUCCESS]"
MESSAGES[WARN_PREFIX]="[WARN]|[WARN]"
MESSAGES[ERROR_PREFIX]="[ERROR]|[ERROR]"

# 环境检查
MESSAGES[CHECK_ENV]="检查系统环境|Checking System Environment"
MESSAGES[DETECTED_OS]="检测到操作系统|Detected Operating System"
MESSAGES[CHECK_CLAUDE]="检查 Claude Code 安装|Checking Claude Code installation"
MESSAGES[CHECK_CURL]="检查 curl 安装|Checking curl installation"
MESSAGES[ENV_CHECK_PASSED]="环境检查全部通过|Environment check passed"
MESSAGES[ENV_CHECK_FAILED]="环境检查未通过，请先完成 Claude Code 的安装|Environment check failed, please complete Claude Code installation first"

# Claude Code 相关
MESSAGES[CLAUDE_NOT_FOUND]="claude 命令未找到|claude command not found"
MESSAGES[CLAUDE_INSTALL_PROMPT]="请先安装 Claude Code|Please install Claude Code first"
MESSAGES[CLAUDE_INSTALL_CMD]="  curl -fsSL https://claude.ai/install.sh | bash|  curl -fsSL https://claude.ai/install.sh | bash"
MESSAGES[CLAUDE_INSTALLED]="Claude Code 已安装|Claude Code is installed"
MESSAGES[DETECT_SHELL]="检测到 Shell|Detected Shell"

# curl
MESSAGES[CURL_NOT_INSTALLED]="curl 未安装，请先安装 curl|curl is not installed, please install curl first"
MESSAGES[CURL_INSTALL_MACOS]="macOS 用户可以使用|macOS users can use"
MESSAGES[CURL_INSTALL_LINUX_DEB]="Ubuntu/Debian|Ubuntu/Debian"
MESSAGES[CURL_INSTALL_LINUX_RPM]="CentOS/RHEL|CentOS/RHEL"

# API Token
MESSAGES[CONFIG_API_TOKEN]="配置 AINFT API Token|Configuring AINFT API Token"
MESSAGES[API_TOKEN_PROMPT]="请前往 https://chat.ainft.com/key 申请 API Token|Please visit https://chat.ainft.com/key to apply for an API Token"
MESSAGES[ENTER_API_TOKEN]="请输入您的 AINFT API Token|Please enter your AINFT API Token"
MESSAGES[API_TOKEN_EMPTY]="API Token 不能为空|API Token cannot be empty"
MESSAGES[API_TOKEN_FORMAT_WARN]="API Token 格式看起来不太常见，请确认是否正确|API Token format looks unusual, please verify"
MESSAGES[API_TOKEN_CONFIRM]="是否继续使用此 API Token?|Continue with this API Token?"
MESSAGES[API_TOKEN_RECEIVED]="API Token 已接收|API Token received"

# 模型相关
MESSAGES[FETCHING_MODELS]="正在从 AINFT API 获取可用模型列表|Fetching available model list from AINFT API"
MESSAGES[FETCH_MODELS_FAILED]="获取模型列表失败|Failed to fetch model list"
MESSAGES[CHECK_API_TOKEN]="请检查您的 API Token 是否正确|Please check if your API Token is correct"
MESSAGES[HTTP_401_HINT]="提示: HTTP 401 表示认证失败，请检查 API Token 是否有效|Hint: HTTP 401 indicates authentication failure, please check if API Token is valid"
MESSAGES[HTTP_000_HINT]="提示: 无法连接到服务器，请检查网络连接|Hint: Cannot connect to server, please check network connection"
MESSAGES[INVALID_RESPONSE_FORMAT]="API 返回数据格式异常|API returned invalid data format"
MESSAGES[NO_MODELS]="未获取到任何模型|No models retrieved"
MESSAGES[MODELS_FETCHED]="成功获取|Successfully fetched"
MESSAGES[MODELS_COUNT]="个模型|models"
MESSAGES[CONFIG_ABORTED]="无法获取模型列表，配置中止|Cannot fetch model list, configuration aborted"

# 选择模型
MESSAGES[SELECT_DEFAULT_MODEL]="选择默认模型|Select Default Model"
MESSAGES[AVAILABLE_MODELS_LIST]="可用模型列表|Available Models"
MESSAGES[RECOMMENDED_MODEL]="推荐默认模型|Recommended default model"
MESSAGES[USE_RECOMMENDED]="是否使用推荐模型作为默认?|Use recommended model as default?"
MESSAGES[ENTER_MODEL_NUMBER]="请输入模型编号|Please enter model number"
MESSAGES[INVALID_SELECTION]="无效的选择，请重新输入|Invalid selection, please try again"
MESSAGES[DEFAULT_MODEL_SET]="默认模型设置为|Default model set to"

# 配置文件
MESSAGES[UPDATE_CONFIG]="更新 Shell 配置文件|Updating Shell Configuration File"
MESSAGES[CONFIG_BACKUP]="原配置已备份到|Original configuration backed up to"
MESSAGES[CONFIG_UPDATED]="配置文件已更新|Configuration file updated"
MESSAGES[SHELL_CONFIG_FILE]="Shell 配置文件|Shell configuration file"

# 验证和测试
MESSAGES[VERIFY_CONFIG]="验证配置|Verifying Configuration"
MESSAGES[RELOAD_CONFIG]="重新加载配置文件|Reloading configuration file"
MESSAGES[RELOAD_CONFIG_HINT]="请运行以下命令使配置生效|Please run the following command to apply the configuration"
MESSAGES[TEST_COMMAND_HINT]="提示: 您可以运行以下命令启动 Claude Code 进行测试|Hint: You can run the following command to start Claude Code for testing"
MESSAGES[TEST_COMMAND]="  claude|  claude"
MESSAGES[CONFIGURED_MODELS]="已配置的模型|Configured Models"
MESSAGES[DEFAULT]="默认|default"
MESSAGES[ENV_SET]="环境变量已设置|Environment variables set"

# 完成
MESSAGES[INSTALL_COMPLETE]="安装完成|Installation Complete"
MESSAGES[CONFIG_SUCCESS]="AINFT Provider 配置成功！|AINFT Provider configured successfully!"
MESSAGES[DEFAULT_MODEL_LABEL]="默认模型|Default Model"
MESSAGES[BASE_URL_LABEL]="API 基础地址|API Base URL"

# 获取本地化消息
get_msg() {
    local key="$1"
    local msg="${MESSAGES[$key]:-$key}"
    if [ "$LANG_CODE" = "zh" ]; then
        echo "$msg" | cut -d'|' -f1
    else
        echo "$msg" | cut -d'|' -f2
    fi
}

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

# 检测当前 shell
detect_shell() {
    local shell_name=$(basename "$SHELL")
    echo "$shell_name"
}

# 获取 shell 配置文件路径
get_shell_config_file() {
    local shell_name=$(detect_shell)
    case "$shell_name" in
        bash)
            echo "$HOME/.bashrc"
            ;;
        zsh)
            echo "$HOME/.zshrc"
            ;;
        fish)
            echo "$HOME/.config/fish/config.fish"
            ;;
        *)
            echo "$HOME/.$(detect_shell)rc"
            ;;
    esac
}

OS=$(detect_os)
SHELL_NAME=$(detect_shell)
SHELL_CONFIG=$(get_shell_config_file)

# 打印带颜色的消息
print_info() {
    echo -e "${INFO}$(get_msg INFO_PREFIX)${NC} $1"
}

print_success() {
    echo -e "${SUCCESS}$(get_msg SUCCESS_PREFIX)${NC} $1"
}

print_warn() {
    echo -e "${WARN}$(get_msg WARN_PREFIX)${NC} $1"
}

print_error() {
    echo -e "${ERROR}$(get_msg ERROR_PREFIX)${NC} $1"
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

# 检查 Claude Code 是否已安装
check_claude_installed() {
    if ! check_command claude; then
        print_error "$(get_msg CLAUDE_NOT_FOUND)"
        print_info "$(get_msg CLAUDE_INSTALL_PROMPT):"
        print_info "$(get_msg CLAUDE_INSTALL_CMD)"
        return 1
    fi

    local version
    version=$(claude --version 2>/dev/null || echo "unknown")
    print_success "$(get_msg CLAUDE_INSTALLED): $version"
    return 0
}

# 检查 curl 是否安装
check_curl() {
    if ! check_command curl; then
        print_error "$(get_msg CURL_NOT_INSTALLED)"
        if [ "$OS" = "macOS" ]; then
            print_info "$(get_msg CURL_INSTALL_MACOS): brew install curl"
        elif [ "$OS" = "Linux" ]; then
            print_info "$(get_msg CURL_INSTALL_LINUX_DEB): sudo apt-get install curl"
            print_info "$(get_msg CURL_INSTALL_LINUX_RPM): sudo yum install curl"
        fi
        return 1
    fi
    return 0
}

# 环境检查
check_environment() {
    print_bold "\n=== $(get_msg CHECK_ENV) ==="
    print_info "$(get_msg DETECTED_OS): $OS"
    print_info "$(get_msg DETECT_SHELL): $SHELL_NAME"

    local all_passed=true

    # 检查 claude
    if ! check_claude_installed; then
        all_passed=false
    fi

    # 检查 curl
    if ! check_curl; then
        all_passed=false
    fi

    if [ "$all_passed" = false ]; then
        print_error "$(get_msg ENV_CHECK_FAILED)"
        exit 1
    fi

    print_success "$(get_msg ENV_CHECK_PASSED)"
}

# 询问用户输入 API Token
ask_api_token() {
    print_bold "\n=== $(get_msg CONFIG_API_TOKEN) ==="
    print_info "$(get_msg API_TOKEN_PROMPT)"
    echo ""

    local api_token
    while true; do
        # 在 macOS 和 Linux 上都兼容的方式读取输入
        if [ -t 0 ]; then
            # 交互式终端
            printf "$(get_msg ENTER_API_TOKEN): "
            read -r api_token
        else
            # 非交互式（管道输入）
            read -r api_token
        fi

        if [ -z "$api_token" ]; then
            print_error "$(get_msg API_TOKEN_EMPTY)"
            continue
        fi

        # 简单的格式检查
        if [[ ! "$api_token" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            print_warn "$(get_msg API_TOKEN_FORMAT_WARN)"
            printf "$(get_msg API_TOKEN_CONFIRM) (y/N): "
            read -r confirm
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                continue
            fi
        fi

        break
    done

    AINFT_API_TOKEN="$api_token"
    print_success "$(get_msg API_TOKEN_RECEIVED)"
}

# 从 API 获取模型列表
fetch_models_from_api() {
    local api_token="$1"
    local response
    local http_code
    local body

    print_info "$(get_msg FETCHING_MODELS)..."

    # 使用 curl 获取模型列表
    response=$(curl -s -w "\n%{http_code}" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${api_token}" \
        "${AINFT_MODELS_API}" 2>/dev/null || echo -e "\n000")

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [ "$http_code" != "200" ]; then
        print_error "$(get_msg FETCH_MODELS_FAILED) (HTTP $http_code)"
        print_info "$(get_msg CHECK_API_TOKEN)"
        if [ "$http_code" = "401" ]; then
            print_info "$(get_msg HTTP_401_HINT)"
        elif [ "$http_code" = "000" ]; then
            print_info "$(get_msg HTTP_000_HINT)"
        fi
        return 1
    fi

    # 检查响应是否包含有效的模型数据
    if command -v jq &>/dev/null; then
        if ! echo "$body" | jq -e '.data' &>/dev/null; then
            print_error "$(get_msg INVALID_RESPONSE_FORMAT)"
            return 1
        fi
        # 提取模型 ID 列表
        AVAILABLE_MODELS=$(echo "$body" | jq -r '.data[].id' 2>/dev/null)
    else
        # 使用 grep/sed 作为备选方案
        AVAILABLE_MODELS=$(echo "$body" | grep -o '"id": "[^"]*"' | sed 's/"id": "//;s/"$//')
    fi

    if [ -z "$AVAILABLE_MODELS" ]; then
        print_error "$(get_msg NO_MODELS)"
        return 1
    fi

    local model_count
    model_count=$(echo "$AVAILABLE_MODELS" | wc -l | tr -d ' ')
    print_success "$(get_msg MODELS_FETCHED) $model_count $(get_msg MODELS_COUNT)"
    return 0
}

# 选择默认模型
select_default_model() {
    print_bold "\n=== $(get_msg SELECT_DEFAULT_MODEL) ==="

    # 将模型列表转换为数组
    local models_array=()
    while IFS= read -r model; do
        models_array+=("$model")
    done <<< "$AVAILABLE_MODELS"

    # 显示可用模型
    print_info "$(get_msg AVAILABLE_MODELS_LIST):"
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
    print_info "$(get_msg RECOMMENDED_MODEL): $recommended"

    # 询问用户是否使用推荐模型
    local use_recommended
    printf "$(get_msg USE_RECOMMENDED) (Y/n): "
    read -r use_recommended

    if [[ ! "$use_recommended" =~ ^[Nn]$ ]]; then
        DEFAULT_MODEL="$recommended"
    else
        # 让用户手动选择
        while true; do
            local selection
            printf "$(get_msg ENTER_MODEL_NUMBER) (1-${#models_array[@]}): "
            read -r selection

            if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le "${#models_array[@]}" ]; then
                DEFAULT_MODEL="${models_array[$((selection-1))]}"
                break
            else
                print_error "$(get_msg INVALID_SELECTION)"
            fi
        done
    fi

    print_success "$(get_msg DEFAULT_MODEL_SET): $DEFAULT_MODEL"
}

# 更新 shell 配置文件
update_shell_config() {
    print_bold "\n=== $(get_msg UPDATE_CONFIG) ==="

    # 备份原配置
    if [ -f "$SHELL_CONFIG" ]; then
        local backup_file="${SHELL_CONFIG}.backup.$(date +%Y%m%d%H%M%S)"
        cp "$SHELL_CONFIG" "$backup_file"
        print_info "$(get_msg CONFIG_BACKUP): $backup_file"
    fi

    # 创建配置文件的目录（如果不存在）
    mkdir -p "$(dirname "$SHELL_CONFIG")"

    # 检查是否已存在 AINFT 相关配置，如果存在则删除
    if [ -f "$SHELL_CONFIG" ]; then
        # 删除旧的 AINFT 配置（在 Claude Code 注释块之间的内容）
        local temp_file="${SHELL_CONFIG}.tmp.$$"
        awk '
            /^# Claude Code - AINFT Provider Configuration/ { skip=1; next }
            skip && /^# End of AINFT Provider Configuration/ { skip=0; next }
            !skip { print }
        ' "$SHELL_CONFIG" > "$temp_file" && mv "$temp_file" "$SHELL_CONFIG"

        # 删除旧的单独环境变量设置（兼容旧版本）
        sed -i.bak '/^export ANTHROPIC_BASE_URL=/d' "$SHELL_CONFIG" 2>/dev/null || \
            sed -i '' '/^export ANTHROPIC_BASE_URL=/d' "$SHELL_CONFIG" 2>/dev/null || true
        sed -i.bak '/^export ANTHROPIC_AUTH_TOKEN=/d' "$SHELL_CONFIG" 2>/dev/null || \
            sed -i '' '/^export ANTHROPIC_AUTH_TOKEN=/d' "$SHELL_CONFIG" 2>/dev/null || true
        sed -i.bak '/^export ANTHROPIC_MODEL=/d' "$SHELL_CONFIG" 2>/dev/null || \
            sed -i '' '/^export ANTHROPIC_MODEL=/d' "$SHELL_CONFIG" 2>/dev/null || true
        rm -f "${SHELL_CONFIG}.bak" 2>/dev/null || true
    fi

    # 添加新的配置
    {
        echo ""
        echo "# Claude Code - AINFT Provider Configuration"
        echo "export ANTHROPIC_BASE_URL=\"${AINFT_BASE_URL}\""
        echo "export ANTHROPIC_AUTH_TOKEN=\"${AINFT_API_TOKEN}\""
        echo "export ANTHROPIC_MODEL=\"${DEFAULT_MODEL}\""
        echo "# End of AINFT Provider Configuration"
    } >> "$SHELL_CONFIG"

    print_success "$(get_msg CONFIG_UPDATED): $SHELL_CONFIG"
}

# 验证配置
verify_config() {
    print_bold "\n=== $(get_msg VERIFY_CONFIG) ==="

    print_info "$(get_msg ENV_SET):"
    echo "  ANTHROPIC_BASE_URL=${AINFT_BASE_URL}"
    echo "  ANTHROPIC_AUTH_TOKEN=********" # 隐藏实际的 token
    echo "  ANTHROPIC_MODEL=${DEFAULT_MODEL}"

    echo ""
    print_info "$(get_msg RELOAD_CONFIG_HINT):"
    echo "  source ${SHELL_CONFIG}"

    echo ""
    print_info "$(get_msg TEST_COMMAND_HINT):"
    print_info "$(get_msg TEST_COMMAND)"
}

# 显示可用模型列表
print_available_models() {
    print_info "$(get_msg CONFIGURED_MODELS):"
    while IFS= read -r model; do
        if [ "$model" = "$DEFAULT_MODEL" ]; then
            echo "  - $model ($(get_msg DEFAULT))"
        else
            echo "  - $model"
        fi
    done <<< "$AVAILABLE_MODELS"
}

# 主函数
main() {
    # 根据语言显示不同的标题
    if [ "$LANG_CODE" = "zh" ]; then
        echo -e "${BOLD}"
        echo "╔══════════════════════════════════════════════════════════════╗"
        echo "║          Claude Code AINFT Provider 安装脚本                 ║"
        echo "║          支持 Linux / macOS                                  ║"
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
    else
        echo -e "${BOLD}"
        echo "╔══════════════════════════════════════════════════════════════╗"
        echo "║          Claude Code AINFT Provider Installation Script      ║"
        echo "║          Supports Linux / macOS                              ║"
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
    fi

    # 检查环境
    check_environment

    # 询问 API Token
    ask_api_token

    # 从 API 获取模型列表
    if ! fetch_models_from_api "$AINFT_API_TOKEN"; then
        # 如果获取失败，使用默认模型列表
        print_warn "$(get_msg FETCH_MODELS_FAILED)，使用默认模型列表"
        AVAILABLE_MODELS="gpt-5-nano\ngpt-5-mini\ngpt-5"
        DEFAULT_MODEL="gpt-5-nano"
    fi

    # 选择默认模型
    if [ -n "$AVAILABLE_MODELS" ]; then
        select_default_model
    fi

    # 更新配置
    update_shell_config

    # 验证配置
    verify_config

    print_bold "\n=== $(get_msg INSTALL_COMPLETE) ==="
    print_success "$(get_msg CONFIG_SUCCESS)"
    echo ""
    print_info "$(get_msg DEFAULT_MODEL_LABEL): $DEFAULT_MODEL"
    print_info "$(get_msg BASE_URL_LABEL): $AINFT_BASE_URL"
    print_info "$(get_msg SHELL_CONFIG_FILE): $SHELL_CONFIG"
    echo ""
    print_available_models
}

# 运行主函数
main "$@"
