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
AINFT_BASE_URL="https://api.ainft.com/v1/"
AINFT_API="openai-completions"
AINFT_MODELS_API="https://api.ainft.com/v1/models"

# 存储获取到的模型列表
AVAILABLE_MODELS=""
DEFAULT_MODEL=""

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
MESSAGES[TITLE]="OpenClaw AINFT Provider 安装脚本|OpenClaw AINFT Provider Installation Script"
MESSAGES[SUPPORT]="支持 Linux / macOS|Supports Linux / macOS"
MESSAGES[INFO_PREFIX]="[INFO]|[INFO]"
MESSAGES[SUCCESS_PREFIX]="[SUCCESS]|[SUCCESS]"
MESSAGES[WARN_PREFIX]="[WARN]|[WARN]"
MESSAGES[ERROR_PREFIX]="[ERROR]|[ERROR]"

# 环境检查
MESSAGES[CHECK_ENV]="检查系统环境|Checking System Environment"
MESSAGES[DETECTED_OS]="检测到操作系统|Detected Operating System"
MESSAGES[CHECK_NODE]="检查 Node.js 版本|Checking Node.js version"
MESSAGES[CHECK_OPENCLAW]="检查 OpenClaw 安装|Checking OpenClaw installation"
MESSAGES[CHECK_CONFIG_DIR]="检查配置目录|Checking configuration directory"
MESSAGES[CHECK_CURL]="检查 curl 安装|Checking curl installation"

MESSAGES[ENV_CHECK_PASSED]="环境检查全部通过|Environment check passed"
MESSAGES[ENV_CHECK_FAILED]="环境检查未通过，请先完成 OpenClaw 的安装和初始化|Environment check failed, please complete OpenClaw installation and initialization first"

# Node.js 相关
MESSAGES[NODE_NOT_INSTALLED]="Node.js 未安装|Node.js is not installed"
MESSAGES[NODE_INSTALL_PROMPT]="请前往 https://nodejs.org/ 安装 Node.js >= 22|Please visit https://nodejs.org/ to install Node.js >= 22"
MESSAGES[NODE_VERSION_LOW]="Node.js 版本需要 >= 22，当前版本|Node.js version >= 22 is required, current version"
MESSAGES[NODE_VERSION_OK]="Node.js 版本检查通过|Node.js version check passed"
MESSAGES[NODE_UPGRADE]="请升级 Node.js|Please upgrade Node.js"

# OpenClaw 相关
MESSAGES[OPENCLAW_NOT_FOUND]="openclaw 命令未找到|openclaw command not found"
MESSAGES[OPENCLAW_INSTALL_PROMPT]="请先安装 OpenClaw|Please install OpenClaw first"
MESSAGES[OPENCLAW_INSTALL_CMD]="  curl -fsSL https://openclaw.bot/install.sh | bash|  curl -fsSL https://openclaw.bot/install.sh | bash"
MESSAGES[OPENCLAW_INSTALLED]="OpenClaw 已安装|OpenClaw is installed"
MESSAGES[CONFIG_DIR_NOT_FOUND]="OpenClaw 配置目录不存在|OpenClaw configuration directory does not exist"
MESSAGES[CONFIG_DIR_PROMPT]="请先运行 'openclaw onboard' 完成初始化配置|Please run 'openclaw onboard' first to complete initialization"
MESSAGES[CONFIG_DIR_OK]="配置目录检查通过|Configuration directory check passed"

# curl
MESSAGES[CURL_NOT_INSTALLED]="curl 未安装，请先安装 curl|curl is not installed, please install curl first"
MESSAGES[CURL_INSTALL_MACOS]="macOS 用户可以使用|macOS users can use"
MESSAGES[CURL_INSTALL_LINUX_DEB]="Ubuntu/Debian|Ubuntu/Debian"
MESSAGES[CURL_INSTALL_LINUX_RPM]="CentOS/RHEL|CentOS/RHEL"

# API Key
MESSAGES[CONFIG_API_KEY]="配置 AINFT API Key|Configuring AINFT API Key"
MESSAGES[API_KEY_PROMPT]="请前往 https://chat.ainft.com/key 申请 API Key|Please visit https://chat.ainft.com/key to apply for an API Key"
MESSAGES[ENTER_API_KEY]="请输入您的 AINFT API Key|Please enter your AINFT API Key"
MESSAGES[API_KEY_EMPTY]="API Key 不能为空|API Key cannot be empty"
MESSAGES[API_KEY_FORMAT_WARN]="API Key 格式看起来不太常见，请确认是否正确|API Key format looks unusual, please verify"
MESSAGES[API_KEY_CONFIRM]="是否继续使用此 API Key?|Continue with this API Key?"
MESSAGES[API_KEY_RECEIVED]="API Key 已接收|API Key received"

# 模型相关
MESSAGES[FETCHING_MODELS]="正在从 AINFT API 获取可用模型列表|Fetching available model list from AINFT API"
MESSAGES[FETCH_MODELS_FAILED]="获取模型列表失败|Failed to fetch model list"
MESSAGES[CHECK_API_KEY]="请检查您的 API Key 是否正确|Please check if your API Key is correct"
MESSAGES[HTTP_401_HINT]="提示: HTTP 401 表示认证失败，请检查 API Key 是否有效|Hint: HTTP 401 indicates authentication failure, please check if API Key is valid"
MESSAGES[HTTP_000_HINT]="提示: 无法连接到服务器，请检查网络连接|Hint: Cannot connect to server, please check network connection"
MESSAGES[INVALID_RESPONSE_FORMAT]="API 返回数据格式异常|API returned invalid data format"
MESSAGES[NO_MODELS]="未获取到任何模型|No models retrieved"
MESSAGES[MODELS_FETCHED]="成功获取|Successfully fetched"
MESSAGES[MODELS_COUNT]="个模型|models"
MESSAGES[CONFIG_ABORTED]="无法获取模型列表，配置中止|Cannot fetch model list, configuration aborted"

# 选择模型
MESSAGES[SELECT_DEFAULT_MODEL]="选择默认模型|Select Default Model"
MESSAGES[AVAILABLE_MODELS_LIST]="可用模型列表|Available Models"
MESSAGES[ENTER_MODEL_NUMBER]="请输入模型编号|Please enter model number"
MESSAGES[INVALID_SELECTION]="无效的选择，请重新输入|Invalid selection, please try again"
MESSAGES[DEFAULT_MODEL_SET]="默认模型设置为|Default model set to"

# 配置文件
MESSAGES[UPDATE_CONFIG]="更新 OpenClaw 配置文件|Updating OpenClaw Configuration File"
MESSAGES[CONFIG_BACKUP]="原配置已备份到|Original configuration backed up to"
MESSAGES[CONFIG_UPDATED]="配置文件已更新|Configuration file updated"
MESSAGES[CONFIG_FILE]="配置文件|Configuration file"

# Gateway
MESSAGES[RESTART_GATEWAY]="重启 OpenClaw Gateway|Restarting OpenClaw Gateway"
MESSAGES[GATEWAY_RESTARTING]="正在重启 Gateway...|Restarting Gateway..."
MESSAGES[GATEWAY_RESTART_SUCCESS]="Gateway 重启成功|Gateway restarted successfully"
MESSAGES[GATEWAY_RESTART_FAILED]="Gateway 重启失败|Gateway restart failed"
MESSAGES[GATEWAY_MANUAL_RESTART]="您可以手动运行|You can manually run"
MESSAGES[GATEWAY_STATUS_CHECK]="检查 Gateway 状态|Checking Gateway status"
MESSAGES[GATEWAY_RUNNING]="Gateway 运行正常|Gateway is running normally"
MESSAGES[GATEWAY_STATUS_FAILED]="Gateway 状态检查失败，请手动检查|Gateway status check failed, please check manually"

# 验证和测试
MESSAGES[VERIFY_CONFIG]="验证配置|Verifying Configuration"
MESSAGES[TEST_COMMAND_HINT]="提示: 您可以运行以下命令测试模型|Hint: You can run the following command to test the model"
MESSAGES[TEST_COMMAND]="  openclaw agent --agent main --message \"你好\"|  openclaw agent --agent main --message \"Hello\""
MESSAGES[CONFIGURED_MODELS]="已配置的模型|Configured Models"
MESSAGES[DEFAULT]="默认|default"
MESSAGES[SWITCH_MODEL_HINT]="如需切换模型，请编辑|To switch models, please edit"
MESSAGES[SWITCH_MODEL_CMD]="或使用命令|Or use command"
MESSAGES[SWITCH_MODEL_CMD_EXAMPLE]="openclaw models set ainft/<model-name>|openclaw models set ainft/<model-name>"

# 完成
MESSAGES[INSTALL_COMPLETE]="安装完成|Installation Complete"
MESSAGES[CONFIG_SUCCESS]="AINFT Provider 配置成功！|AINFT Provider configured successfully!"
MESSAGES[DEFAULT_MODEL_LABEL]="默认模型|Default Model"

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

OS=$(detect_os)

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

# 检查 Node.js 版本
check_node_version() {
    local node_version
    local major_version

    if ! check_command node; then
        print_error "$(get_msg NODE_NOT_INSTALLED)"
        print_info "$(get_msg NODE_INSTALL_PROMPT)"
        return 1
    fi

    node_version=$(node -v | run_node_json 'const fs=require("fs"); const v=fs.readFileSync(0,"utf-8").trim(); console.log(v.replace(/^v/,""));')
    major_version=$(echo "$node_version" | run_node_json 'const fs=require("fs"); const v=fs.readFileSync(0,"utf-8").trim(); console.log(v.split(".")[0]);')

    if [ "$major_version" -lt 22 ]; then
        print_error "$(get_msg NODE_VERSION_LOW): $node_version"
        print_info "$(get_msg NODE_UPGRADE): https://nodejs.org/"
        return 1
    fi

    print_success "$(get_msg NODE_VERSION_OK): v$node_version"
    return 0
}

# 检查 openclaw 是否已安装
check_openclaw_installed() {
    if ! check_command openclaw; then
        print_error "$(get_msg OPENCLAW_NOT_FOUND)"
        print_info "$(get_msg OPENCLAW_INSTALL_PROMPT):"
        print_info "$(get_msg OPENCLAW_INSTALL_CMD)"
        return 1
    fi

    local version
    version=$(openclaw --version 2>/dev/null || echo "unknown")
    print_success "$(get_msg OPENCLAW_INSTALLED): $version"
    return 0
}

# 检查配置文件目录是否存在
check_config_dir() {
    if [ ! -d "$OPENCLAW_CONFIG_DIR" ]; then
        print_error "$(get_msg CONFIG_DIR_NOT_FOUND): $OPENCLAW_CONFIG_DIR"
        print_info "$(get_msg CONFIG_DIR_PROMPT)"
        return 1
    fi
    print_success "$(get_msg CONFIG_DIR_OK): $OPENCLAW_CONFIG_DIR"
    return 0
}

# 使用 Node.js 执行 JavaScript 代码处理 JSON
# 参数: $1 = JavaScript 代码字符串
run_node_json() {
    node -e "$1"
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
        print_error "$(get_msg ENV_CHECK_FAILED)"
        exit 1
    fi

    print_success "$(get_msg ENV_CHECK_PASSED)"
}

# 询问用户输入 API Key
ask_api_key() {
    print_bold "\n=== $(get_msg CONFIG_API_KEY) ==="
    print_info "$(get_msg API_KEY_PROMPT)"
    echo ""

    local api_key
    while true; do
        # 在 macOS 和 Linux 上都兼容的方式读取输入
        if [ -t 0 ]; then
            # 交互式终端
            printf "$(get_msg ENTER_API_KEY): "
            read -r api_key
        else
            # 非交互式（管道输入）
            read -r api_key
        fi

        if [ -z "$api_key" ]; then
            print_error "$(get_msg API_KEY_EMPTY)"
            continue
        fi

        # 简单的格式检查
        if [[ ! "$api_key" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            print_warn "$(get_msg API_KEY_FORMAT_WARN)"
            printf "$(get_msg API_KEY_CONFIRM) (y/N): "
            read -r confirm
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                continue
            fi
        fi

        break
    done

    AINFT_API_KEY="$api_key"
    print_success "$(get_msg API_KEY_RECEIVED)"
}

# 从 API 获取模型列表
fetch_models_from_api() {
    local api_key="$1"
    local response
    local http_code
    local body

    print_info "$(get_msg FETCHING_MODELS)..."

    # 使用 curl 获取模型列表
    response=$(curl -s -w "\n%{http_code}" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer ${api_key}" \
        "${AINFT_MODELS_API}" 2>/dev/null || echo -e "\n000")

    http_code=$(echo "$response" | run_node_json 'const fs=require("fs"); const lines=fs.readFileSync(0,"utf-8").trim().split("\n"); console.log(lines.pop());')
    body=$(echo "$response" | run_node_json 'const fs=require("fs"); const lines=fs.readFileSync(0,"utf-8").trim().split("\n"); lines.pop(); console.log(lines.join("\n"));')

    if [ "$http_code" != "200" ]; then
        print_error "$(get_msg FETCH_MODELS_FAILED) (HTTP $http_code)"
        print_info "$(get_msg CHECK_API_KEY)"
        if [ "$http_code" = "401" ]; then
            print_info "$(get_msg HTTP_401_HINT)"
        elif [ "$http_code" = "000" ]; then
            print_info "$(get_msg HTTP_000_HINT)"
        fi
        return 1
    fi

    # 使用 Node.js 解析 JSON 响应
    if ! echo "$body" | run_node_json 'const data=""; try { const obj=JSON.parse(require("fs").readFileSync(0,"utf-8")); if(!obj.data||!Array.isArray(obj.data)) process.exit(1); } catch(e) { process.exit(1); }'; then
        print_error "$(get_msg INVALID_RESPONSE_FORMAT)"
        return 1
    fi

    # 提取模型 ID 列表
    AVAILABLE_MODELS=$(echo "$body" | run_node_json 'const fs=require("fs"); const obj=JSON.parse(fs.readFileSync(0,"utf-8")); console.log(obj.data.map(m=>m.id).join("\n"));')

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

    echo ""

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

    print_success "$(get_msg DEFAULT_MODEL_SET): $DEFAULT_MODEL"
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

# 使用 Node.js 更新配置文件
update_config_with_node() {
    local config_file="$1"
    local api_key="$2"

    # 如果文件不存在，创建基本结构
    if [ ! -f "$config_file" ]; then
        echo '{}' > "$config_file"
    fi

    # 读取现有配置
    local config_content
    config_content=$(cat "$config_file")

    # 将模型列表转换为数组
    local models_array=()
    while IFS= read -r model; do
        models_array+=("$model")
    done <<< "$AVAILABLE_MODELS"

    # 构建模型 JSON 数组字符串
    local models_json=""
    local first=true
    for model in "${models_array[@]}"; do
        if [ "$first" = true ]; then
            first=false
        else
            models_json="${models_json},"
        fi
        models_json="${models_json}{\"id\":\"${model}\",\"name\":\"${model}\"}"
    done

    # 使用 Node.js 合并配置
    node -e "
const fs = require('fs');
const path = '$config_file';
let config = $config_content;
if (typeof config !== 'object' || config === null) config = {};
if (!config.models) config.models = {};
if (!config.models.providers) config.models.providers = {};
config.models.mode = 'merge';
config.models.providers.ainft = {
    baseUrl: '$AINFT_BASE_URL',
    apiKey: '$api_key',
    api: '$AINFT_API',
    models: [$models_json]
};
if (!config.agents) config.agents = {};
if (!config.agents.defaults) config.agents.defaults = {};
if (!config.agents.defaults.model) config.agents.defaults.model = {};
config.agents.defaults.model.primary = 'ainft/$DEFAULT_MODEL';
fs.writeFileSync(path, JSON.stringify(config, null, 2));
console.log('Configuration updated successfully');
"
}

# 更新配置文件
update_config() {
    print_bold "\n=== $(get_msg UPDATE_CONFIG) ==="

    # 备份原配置
    if [ -f "$OPENCLAW_CONFIG_FILE" ]; then
        local backup_file="${OPENCLAW_CONFIG_FILE}.backup.$(date +%Y%m%d%H%M%S)"
        cp "$OPENCLAW_CONFIG_FILE" "$backup_file"
        print_info "$(get_msg CONFIG_BACKUP): $backup_file"
    fi

    # 使用 Node.js 更新配置
    update_config_with_node "$OPENCLAW_CONFIG_FILE" "$AINFT_API_KEY"

    print_success "$(get_msg CONFIG_UPDATED): $OPENCLAW_CONFIG_FILE"
}

# 重启 Gateway
restart_gateway() {
    print_bold "\n=== $(get_msg RESTART_GATEWAY) ==="

    if ! check_command openclaw; then
        print_error "$(get_msg OPENCLAW_NOT_FOUND)，$(get_msg GATEWAY_RESTART_FAILED)"
        return 1
    fi

    print_info "$(get_msg GATEWAY_RESTARTING)..."
    if openclaw gateway restart; then
        print_success "$(get_msg GATEWAY_RESTART_SUCCESS)"
    else
        print_error "$(get_msg GATEWAY_RESTART_FAILED)"
        print_info "$(get_msg GATEWAY_MANUAL_RESTART): openclaw gateway restart"
        return 1
    fi
}

# 验证配置
verify_config() {
    print_bold "\n=== $(get_msg VERIFY_CONFIG) ==="

    print_info "$(get_msg GATEWAY_STATUS_CHECK)..."
    if openclaw gateway status &>/dev/null; then
        print_success "$(get_msg GATEWAY_RUNNING)"
    else
        print_warn "$(get_msg GATEWAY_STATUS_FAILED)"
    fi

    print_info "$(get_msg TEST_COMMAND_HINT):"
    print_info "$(get_msg TEST_COMMAND)"
}

# 显示可用模型列表
print_available_models() {
    print_info "$(get_msg CONFIGURED_MODELS):"
    while IFS= read -r model; do
        if [ "$model" = "$DEFAULT_MODEL" ]; then
            echo "  - ainft/$model ($(get_msg DEFAULT))"
        else
            echo "  - ainft/$model"
        fi
    done <<< "$AVAILABLE_MODELS"
}

# 主函数
main() {
    # 根据语言显示不同的标题
    if [ "$LANG_CODE" = "zh" ]; then
        echo -e "${BOLD}"
        echo "╔══════════════════════════════════════════════════════════════╗"
        echo "║          OpenClaw AINFT Provider 安装脚本                    ║"
        echo "║          支持 Linux / macOS                                  ║"
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
    else
        echo -e "${BOLD}"
        echo "╔══════════════════════════════════════════════════════════════╗"
        echo "║          OpenClaw AINFT Provider Installation Script         ║"
        echo "║          Supports Linux / macOS                              ║"
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo -e "${NC}"
    fi

    # 检查环境
    check_environment

    # 询问 API Key
    ask_api_key

    # 从 API 获取模型列表
    if ! fetch_models_from_api "$AINFT_API_KEY"; then
        print_error "$(get_msg CONFIG_ABORTED)"
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

    print_bold "\n=== $(get_msg INSTALL_COMPLETE) ==="
    print_success "$(get_msg CONFIG_SUCCESS)"
    echo ""
    print_info "$(get_msg DEFAULT_MODEL_LABEL): ainft/$DEFAULT_MODEL"
    print_info "$(get_msg CONFIG_FILE): $OPENCLAW_CONFIG_FILE"
    echo ""
    print_available_models
    echo ""
    print_info "$(get_msg SWITCH_MODEL_HINT) ~/.openclaw/openclaw.json"
    print_info "$(get_msg SWITCH_MODEL_CMD): $(get_msg SWITCH_MODEL_CMD_EXAMPLE)"
}

# 运行主函数
main "$@"
