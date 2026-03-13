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

# 多语言消息定义 - 使用函数方式兼容 Bash 3.2
# 格式: 每个 key 对应一个函数，返回 "zh_message|en_message"

# 标题和通用
msg_TITLE() { echo "OpenClaw AINFT Provider 安装脚本|OpenClaw AINFT Provider Installation Script"; }
msg_SUPPORT() { echo "支持 Linux / macOS|Supports Linux / macOS"; }
msg_INFO_PREFIX() { echo "[INFO]|[INFO]"; }
msg_SUCCESS_PREFIX() { echo "[SUCCESS]|[SUCCESS]"; }
msg_WARN_PREFIX() { echo "[WARN]|[WARN]"; }
msg_ERROR_PREFIX() { echo "[ERROR]|[ERROR]"; }

# 环境检查
msg_CHECK_ENV() { echo "检查系统环境|Checking System Environment"; }
msg_DETECTED_OS() { echo "检测到操作系统|Detected Operating System"; }
msg_CHECK_NODE() { echo "检查 Node.js 版本|Checking Node.js version"; }
msg_CHECK_OPENCLAW() { echo "检查 OpenClaw 安装|Checking OpenClaw installation"; }
msg_CHECK_CONFIG_DIR() { echo "检查配置目录|Checking configuration directory"; }
msg_CHECK_CURL() { echo "检查 curl 安装|Checking curl installation"; }

msg_ENV_CHECK_PASSED() { echo "环境检查全部通过|Environment check passed"; }
msg_ENV_CHECK_FAILED() { echo "环境检查未通过，请先完成 OpenClaw 的安装和初始化|Environment check failed, please complete OpenClaw installation and initialization first"; }

# Node.js 相关
msg_NODE_NOT_INSTALLED() { echo "Node.js 未安装|Node.js is not installed"; }
msg_NODE_INSTALL_PROMPT() { echo "请前往 https://nodejs.org/ 安装 Node.js >= 22|Please visit https://nodejs.org/ to install Node.js >= 22"; }
msg_NODE_VERSION_LOW() { echo "Node.js 版本需要 >= 22，当前版本|Node.js version >= 22 is required, current version"; }
msg_NODE_VERSION_OK() { echo "Node.js 版本检查通过|Node.js version check passed"; }
msg_NODE_UPGRADE() { echo "请升级 Node.js|Please upgrade Node.js"; }

# OpenClaw 相关
msg_OPENCLAW_NOT_FOUND() { echo "openclaw 命令未找到|openclaw command not found"; }
msg_OPENCLAW_INSTALL_PROMPT() { echo "请先安装 OpenClaw|Please install OpenClaw first"; }
msg_OPENCLAW_INSTALL_CMD() { echo "  curl -fsSL https://openclaw.bot/install.sh | bash|  curl -fsSL https://openclaw.bot/install.sh | bash"; }
msg_OPENCLAW_INSTALLED() { echo "OpenClaw 已安装|OpenClaw is installed"; }
msg_CONFIG_DIR_NOT_FOUND() { echo "OpenClaw 配置目录不存在|OpenClaw configuration directory does not exist"; }
msg_CONFIG_DIR_PROMPT() { echo "请先运行 'openclaw onboard' 完成初始化配置|Please run 'openclaw onboard' first to complete initialization"; }
msg_CONFIG_DIR_OK() { echo "配置目录检查通过|Configuration directory check passed"; }
msg_CONFIG_FILE_NOT_FOUND() { echo "OpenClaw 配置文件不存在|OpenClaw configuration file does not exist"; }
msg_CONFIG_FILE_PROMPT() { echo "请先运行 'openclaw onboard' 完成初始化配置|Please run 'openclaw onboard' first to complete initialization"; }

# curl
msg_CURL_NOT_INSTALLED() { echo "curl 未安装，请先安装 curl|curl is not installed, please install curl first"; }
msg_CURL_INSTALL_MACOS() { echo "macOS 用户可以使用|macOS users can use"; }
msg_CURL_INSTALL_LINUX_DEB() { echo "Ubuntu/Debian|Ubuntu/Debian"; }
msg_CURL_INSTALL_LINUX_RPM() { echo "CentOS/RHEL|CentOS/RHEL"; }

# API Key
msg_CONFIG_API_KEY() { echo "配置 AINFT API Key|Configuring AINFT API Key"; }
msg_API_KEY_PROMPT() { echo "请前往 https://chat.ainft.com/key 申请 API Key|Please visit https://chat.ainft.com/key to apply for an API Key"; }
msg_ENTER_API_KEY() { echo "请输入您的 AINFT API Key|Please enter your AINFT API Key"; }
msg_API_KEY_EMPTY() { echo "API Key 不能为空|API Key cannot be empty"; }
msg_API_KEY_FORMAT_WARN() { echo "API Key 格式看起来不太常见，请确认是否正确|API Key format looks unusual, please verify"; }
msg_API_KEY_CONFIRM() { echo "是否继续使用此 API Key?|Continue with this API Key?"; }
msg_API_KEY_RECEIVED() { echo "API Key 已接收|API Key received"; }

# 模型相关
msg_FETCHING_MODELS() { echo "正在从 AINFT API 获取可用模型列表|Fetching available model list from AINFT API"; }
msg_FETCH_MODELS_FAILED() { echo "获取模型列表失败|Failed to fetch model list"; }
msg_CHECK_API_KEY() { echo "请检查您的 API Key 是否正确|Please check if your API Key is correct"; }
msg_HTTP_401_HINT() { echo "提示: HTTP 401 表示认证失败，请检查 API Key 是否有效|Hint: HTTP 401 indicates authentication failure, please check if API Key is valid"; }
msg_HTTP_000_HINT() { echo "提示: 无法连接到服务器，请检查网络连接|Hint: Cannot connect to server, please check network connection"; }
msg_INVALID_RESPONSE_FORMAT() { echo "API 返回数据格式异常|API returned invalid data format"; }
msg_NO_MODELS() { echo "未获取到任何模型|No models retrieved"; }
msg_MODELS_FETCHED() { echo "成功获取|Successfully fetched"; }
msg_MODELS_COUNT() { echo "个模型|models"; }
msg_CONFIG_ABORTED() { echo "无法获取模型列表，配置中止|Cannot fetch model list, configuration aborted"; }

# 选择模型
msg_SELECT_DEFAULT_MODEL() { echo "选择默认模型|Select Default Model"; }
msg_AVAILABLE_MODELS_LIST() { echo "可用模型列表|Available Models"; }
msg_ENTER_MODEL_NUMBER() { echo "请输入模型编号|Please enter model number"; }
msg_INVALID_SELECTION() { echo "无效的选择，请重新输入|Invalid selection, please try again"; }
msg_DEFAULT_MODEL_SET() { echo "默认模型设置为|Default model set to"; }

# 配置文件
msg_UPDATE_CONFIG() { echo "更新 OpenClaw 配置文件|Updating OpenClaw Configuration File"; }
msg_CONFIG_BACKUP() { echo "原配置已备份到|Original configuration backed up to"; }
msg_CONFIG_UPDATED() { echo "配置文件已更新|Configuration file updated"; }
msg_CONFIG_FILE() { echo "配置文件|Configuration file"; }

# Gateway
msg_RESTART_GATEWAY() { echo "重启 OpenClaw Gateway|Restarting OpenClaw Gateway"; }
msg_GATEWAY_RESTARTING() { echo "正在重启 Gateway...|Restarting Gateway..."; }
msg_GATEWAY_RESTART_SUCCESS() { echo "Gateway 重启成功|Gateway restarted successfully"; }
msg_GATEWAY_RESTART_FAILED() { echo "Gateway 重启失败|Gateway restart failed"; }
msg_GATEWAY_MANUAL_RESTART() { echo "您可以手动运行|You can manually run"; }
msg_GATEWAY_STATUS_CHECK() { echo "检查 Gateway 状态|Checking Gateway status"; }
msg_GATEWAY_RUNNING() { echo "Gateway 运行正常|Gateway is running normally"; }
msg_GATEWAY_STATUS_FAILED() { echo "Gateway 状态检查失败，请手动检查|Gateway status check failed, please check manually"; }

# 验证和测试
msg_VERIFY_CONFIG() { echo "验证配置|Verifying Configuration"; }
msg_TEST_COMMAND_HINT() { echo "提示: 您可以运行以下命令测试模型|Hint: You can run the following command to test the model"; }
msg_TEST_COMMAND() { echo "  openclaw agent --agent main --message \"你好\"|  openclaw agent --agent main --message \"Hello\""; }
msg_CONFIGURED_MODELS() { echo "已配置的模型|Configured Models"; }
msg_DEFAULT() { echo "默认|default"; }
msg_SWITCH_MODEL_HINT() { echo "如需切换模型，请编辑|To switch models, please edit"; }
msg_SWITCH_MODEL_CMD() { echo "或使用命令|Or use command"; }
msg_SWITCH_MODEL_CMD_EXAMPLE() { echo "openclaw models set ainft/<model-name>|openclaw models set ainft/<model-name>"; }

# 完成
msg_INSTALL_COMPLETE() { echo "安装完成|Installation Complete"; }
msg_CONFIG_SUCCESS() { echo "AINFT Provider 配置成功！|AINFT Provider configured successfully!"; }
msg_DEFAULT_MODEL_LABEL() { echo "默认模型|Default Model"; }

# 获取本地化消息
get_msg() {
    local key="$1"
    local msg
    # 检查对应的函数是否存在，存在则调用，否则返回 key
    if type "msg_$key" >/dev/null 2>&1; then
        msg=$("msg_$key")
    else
        msg="$key"
    fi
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

# 检查配置文件是否存在
check_config_file() {
    if [ ! -f "$OPENCLAW_CONFIG_FILE" ]; then
        print_error "$(get_msg CONFIG_FILE_NOT_FOUND): $OPENCLAW_CONFIG_FILE"
        print_info "$(get_msg CONFIG_FILE_PROMPT)"
        return 1
    fi
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

    # 检查配置文件
    if ! check_config_file; then
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

# 从终端读取输入（支持交互式和非交互式环境）
# 兼容 Bash 3.2，不使用 ${var^^} 和 ${!var} 语法
read_from_terminal() {
    local var_name="$1"
    local prompt="$2"
    
    # 如果环境变量中已设置值，直接使用（用于 CI/自动化场景）
    # 使用 tr 进行大写转换，兼容 Bash 3.2
    local env_var_name
    env_var_name=$(echo "INSTALL_$var_name" | tr '[:lower:]' '[:upper:]')
    
    # 使用 eval 进行间接引用，兼容 Bash 3.2
    # 使用 :- 处理未定义变量，避免 set -u 报错
    local env_value
    eval "env_value=\"\${$env_var_name:-}\""
    
    if [ -n "$env_value" ]; then
        eval "$var_name='\$env_value'"
        return 0
    fi
    
    # 检查 /dev/tty 是否可用（真正的交互式终端）
    if [ -e /dev/tty ] && [ -r /dev/tty ] && [ -w /dev/tty ]; then
        # 测试 /dev/tty 是否真的可用
        if printf "" > /dev/tty 2>/dev/null; then
            printf "%s" "$prompt" > /dev/tty
            read -r "$var_name" < /dev/tty
            return 0
        fi
    fi
    
    # 回退：输出提示到 stderr，从 stdin 读取
    printf "%s" "$prompt" >&2
    read -r "$var_name"
}

# 询问用户输入 API Key
ask_api_key() {
    print_bold "\n=== $(get_msg CONFIG_API_KEY) ==="
    print_info "$(get_msg API_KEY_PROMPT)"
    echo ""

    local api_key
    while true; do
        # 使用 /dev/tty 强制从终端读取输入
        read_from_terminal api_key "$(get_msg ENTER_API_KEY): "

        if [ -z "$api_key" ]; then
            print_error "$(get_msg API_KEY_EMPTY)"
            continue
        fi

        # 简单的格式检查
        if [[ ! "$api_key" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            print_warn "$(get_msg API_KEY_FORMAT_WARN)"
            local confirm
            read_from_terminal confirm "$(get_msg API_KEY_CONFIRM) (y/N): "
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

    # 显示可用模型（输出到 stderr，避免影响管道）
    print_info "$(get_msg AVAILABLE_MODELS_LIST):"
    local i=1
    for model in "${models_array[@]}"; do
        echo "  $i) $model" >&2
        ((i++))
    done

    echo "" >&2

    # 让用户手动选择
    while true; do
        local selection
        read_from_terminal selection "$(get_msg ENTER_MODEL_NUMBER) (1-${#models_array[@]}): "

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

// 构建 agents.defaults.models 对象格式
const modelsObj = {};
const modelList = [$models_json];
modelList.forEach(m => {
    modelsObj['ainft/' + m.id] = { alias: m.id };
});
config.agents.defaults.models = modelsObj;

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
