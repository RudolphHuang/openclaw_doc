#Requires -Version 5.1
<#
.SYNOPSIS
    OpenClaw AINFT Provider 安装脚本 (Windows PowerShell)

.DESCRIPTION
    用于在 Windows 上自动配置 AINFT 作为 OpenClaw 的模型提供商

.EXAMPLE
    iwr -useb https://chat.ainft.com/scripts/install-ainft-provider.ps1 | iex

    或者下载后执行:
    .\install-ainft-provider.ps1
#>

[CmdletBinding()]
param()

# 错误处理
$ErrorActionPreference = "Stop"

# 配置路径
$script:OpenClawConfigDir = Join-Path $env:USERPROFILE ".openclaw"
$script:OpenClawConfigFile = Join-Path $script:OpenClawConfigDir "openclaw.json"

# AINFT Provider 配置
$script:AinftBaseUrl = "https://api.ainft.com/v1/"
$script:AinftApi = "openai-completions"
$script:AinftModelsApi = "https://api.ainft.com/v1/models"

# 存储获取到的模型列表
$script:AvailableModels = @()
$script:DefaultModel = ""

# 检测系统语言（中文环境返回 zh，其他返回 en）
function Get-SystemLanguage {
    $culture = [System.Globalization.CultureInfo]::CurrentUICulture
    $langCode = $culture.Name

    # 检查是否为中文语言代码
    if ($langCode -match '^(zh|zh-CN|zh-TW|zh-HK|zh-SG)') {
        return "zh"
    }
    return "en"
}

# 设置语言
$script:LangCode = Get-SystemLanguage

# 多语言消息定义
$script:Messages = @{
    # 前缀
    INFO_PREFIX = @("[INFO]", "[INFO]")
    SUCCESS_PREFIX = @("[SUCCESS]", "[SUCCESS]")
    WARN_PREFIX = @("[WARN]", "[WARN]")
    ERROR_PREFIX = @("[ERROR]", "[ERROR]")

    # 环境检查
    CHECK_ENV = @("检查系统环境", "Checking System Environment")
    DETECTED_OS = @("检测到操作系统", "Detected Operating System")
    ENV_CHECK_PASSED = @("环境检查全部通过", "Environment check passed")
    ENV_CHECK_FAILED = @("环境检查未通过，请先完成 OpenClaw 的安装和初始化", "Environment check failed, please complete OpenClaw installation and initialization first")

    # Node.js 相关
    NODE_NOT_INSTALLED = @("Node.js 未安装", "Node.js is not installed")
    NODE_INSTALL_PROMPT = @("请前往 https://nodejs.org/ 安装 Node.js >= 22", "Please visit https://nodejs.org/ to install Node.js >= 22")
    NODE_VERSION_LOW = @("Node.js 版本需要 >= 22，当前版本", "Node.js version >= 22 is required, current version")
    NODE_VERSION_OK = @("Node.js 版本检查通过", "Node.js version check passed")
    NODE_UPGRADE = @("请升级 Node.js", "Please upgrade Node.js")

    # OpenClaw 相关
    OPENCLAW_NOT_FOUND = @("openclaw 命令未找到", "openclaw command not found")
    OPENCLAW_INSTALL_PROMPT = @("请先安装 OpenClaw", "Please install OpenClaw first")
    OPENCLAW_INSTALL_CMD = @("  iwr -useb https://openclaw.ai/install.ps1 | iex", "  iwr -useb https://openclaw.ai/install.ps1 | iex")
    OPENCLAW_INSTALLED = @("OpenClaw 已安装", "OpenClaw is installed")
    CONFIG_DIR_NOT_FOUND = @("OpenClaw 配置目录不存在", "OpenClaw configuration directory does not exist")
    CONFIG_DIR_PROMPT = @("请先运行 'openclaw onboard' 完成初始化配置", "Please run 'openclaw onboard' first to complete initialization")
    CONFIG_DIR_OK = @("配置目录检查通过", "Configuration directory check passed")

    # API Key
    CONFIG_API_KEY = @("配置 AINFT API Key", "Configuring AINFT API Key")
    API_KEY_PROMPT = @("请前往 https://chat.ainft.com/key 申请 API Key", "Please visit https://chat.ainft.com/key to apply for an API Key")
    ENTER_API_KEY = @("请输入您的 AINFT API Key", "Please enter your AINFT API Key")
    API_KEY_EMPTY = @("API Key 不能为空", "API Key cannot be empty")
    API_KEY_FORMAT_WARN = @("API Key 格式看起来不太常见，请确认是否正确", "API Key format looks unusual, please verify")
    API_KEY_CONFIRM = @("是否继续使用此 API Key?", "Continue with this API Key?")
    API_KEY_RECEIVED = @("API Key 已接收", "API Key received")

    # 模型相关
    FETCHING_MODELS = @("正在从 AINFT API 获取可用模型列表", "Fetching available model list from AINFT API")
    FETCH_MODELS_FAILED = @("获取模型列表失败", "Failed to fetch model list")
    HTTP_401_HINT = @("提示: HTTP 401 表示认证失败，请检查 API Key 是否有效", "Hint: HTTP 401 indicates authentication failure, please check if API Key is valid")
    INVALID_RESPONSE_FORMAT = @("API 返回数据格式异常", "API returned invalid data format")
    NO_MODELS = @("未获取到任何模型", "No models retrieved")
    MODELS_FETCHED = @("成功获取", "Successfully fetched")
    MODELS_COUNT = @("个模型", "models")
    CONFIG_ABORTED = @("无法获取模型列表，配置中止", "Cannot fetch model list, configuration aborted")

    # 选择模型
    SELECT_DEFAULT_MODEL = @("选择默认模型", "Select Default Model")
    AVAILABLE_MODELS_LIST = @("可用模型列表", "Available Models")
    ENTER_MODEL_NUMBER = @("请输入模型编号", "Please enter model number")
    INVALID_SELECTION = @("无效的选择，请重新输入", "Invalid selection, please try again")
    DEFAULT_MODEL_SET = @("默认模型设置为", "Default model set to")

    # 配置文件
    UPDATE_CONFIG = @("更新 OpenClaw 配置文件", "Updating OpenClaw Configuration File")
    CONFIG_BACKUP = @("原配置已备份到", "Original configuration backed up to")
    CONFIG_UPDATED = @("配置文件已更新", "Configuration file updated")
    CONFIG_FILE = @("配置文件", "Configuration file")

    # Gateway
    RESTART_GATEWAY = @("重启 OpenClaw Gateway", "Restarting OpenClaw Gateway")
    GATEWAY_RESTARTING = @("正在重启 Gateway...", "Restarting Gateway...")
    GATEWAY_RESTART_SUCCESS = @("Gateway 重启成功", "Gateway restarted successfully")
    GATEWAY_RESTART_FAILED = @("Gateway 重启失败", "Gateway restart failed")
    GATEWAY_MANUAL_RESTART = @("您可以手动运行", "You can manually run")
    GATEWAY_STATUS_CHECK = @("检查 Gateway 状态", "Checking Gateway status")
    GATEWAY_RUNNING = @("Gateway 运行正常", "Gateway is running normally")
    GATEWAY_STATUS_FAILED = @("Gateway 状态检查失败，请手动检查", "Gateway status check failed, please check manually")

    # 验证和测试
    VERIFY_CONFIG = @("验证配置", "Verifying Configuration")
    TEST_COMMAND_HINT = @("提示: 您可以运行以下命令测试模型", "Hint: You can run the following command to test the model")
    TEST_COMMAND = @('  openclaw agent --agent main --message "你好"', '  openclaw agent --agent main --message "Hello"')
    CONFIGURED_MODELS = @("已配置的模型", "Configured Models")
    DEFAULT = @("默认", "default")
    SWITCH_MODEL_HINT = @("如需切换模型，请编辑", "To switch models, please edit")
    SWITCH_MODEL_CMD = @("或使用命令", "Or use command")
    SWITCH_MODEL_CMD_EXAMPLE = @("openclaw models set ainft/<model-name>", "openclaw models set ainft/<model-name>")

    # 完成
    INSTALL_COMPLETE = @("安装完成", "Installation Complete")
    CONFIG_SUCCESS = @("AINFT Provider 配置成功！", "AINFT Provider configured successfully!")
    DEFAULT_MODEL_LABEL = @("默认模型", "Default Model")

    # 标题
    TITLE = @("OpenClaw AINFT Provider 安装脚本", "OpenClaw AINFT Provider Installation Script")
    SUPPORT = @("支持 Windows PowerShell", "Supports Windows PowerShell")
}

# 获取本地化消息
function Get-Message($Key) {
    $msg = $script:Messages[$Key]
    if ($null -eq $msg) {
        return $Key
    }
    if ($script:LangCode -eq "zh") {
        return $msg[0]
    }
    return $msg[1]
}

# 颜色定义
function Write-Info($Message) {
    $prefix = Get-Message "INFO_PREFIX"
    Write-Host "$prefix $Message" -ForegroundColor Cyan
}

function Write-Success($Message) {
    $prefix = Get-Message "SUCCESS_PREFIX"
    Write-Host "$prefix $Message" -ForegroundColor Green
}

function Write-Warn($Message) {
    $prefix = Get-Message "WARN_PREFIX"
    Write-Host "$prefix $Message" -ForegroundColor Yellow
}

function Write-Error($Message) {
    $prefix = Get-Message "ERROR_PREFIX"
    Write-Host "$prefix $Message" -ForegroundColor Red
}

function Write-Bold($Message) {
    Write-Host $Message -ForegroundColor White -Bold
}

# 检查命令是否存在
function Test-Command($Command) {
    return [bool](Get-Command -Name $Command -ErrorAction SilentlyContinue)
}

# 检查 Node.js 版本
function Test-NodeVersion {
    if (-not (Test-Command "node")) {
        Write-Error (Get-Message "NODE_NOT_INSTALLED")
        Write-Info (Get-Message "NODE_INSTALL_PROMPT")
        return $false
    }

    $nodeVersion = (node -v) -replace 'v', ''
    $majorVersion = [int]($nodeVersion -split '\.')[0]

    if ($majorVersion -lt 22) {
        Write-Error "$(Get-Message "NODE_VERSION_LOW"): $nodeVersion"
        Write-Info "$(Get-Message "NODE_UPGRADE"): https://nodejs.org/"
        return $false
    }

    Write-Success "$(Get-Message "NODE_VERSION_OK"): v$nodeVersion"
    return $true
}

# 检查 openclaw 是否已安装
function Test-OpenClawInstalled {
    if (-not (Test-Command "openclaw")) {
        Write-Error (Get-Message "OPENCLAW_NOT_FOUND")
        Write-Info "$(Get-Message "OPENCLAW_INSTALL_PROMPT"):"
        Write-Info (Get-Message "OPENCLAW_INSTALL_CMD")
        return $false
    }

    try {
        $version = openclaw --version 2>$null
        if (-not $version) { $version = "unknown" }
    }
    catch {
        $version = "unknown"
    }

    Write-Success "$(Get-Message "OPENCLAW_INSTALLED"): $version"
    return $true
}

# 检查配置文件目录是否存在
function Test-ConfigDir {
    if (-not (Test-Path $script:OpenClawConfigDir -PathType Container)) {
        Write-Error "$(Get-Message "CONFIG_DIR_NOT_FOUND"): $script:OpenClawConfigDir"
        Write-Info (Get-Message "CONFIG_DIR_PROMPT")
        return $false
    }
    Write-Success "$(Get-Message "CONFIG_DIR_OK"): $script:OpenClawConfigDir"
    return $true
}

# 环境检查
function Test-Environment {
    Write-Bold "`n=== $(Get-Message "CHECK_ENV") ==="
    Write-Info "$(Get-Message "DETECTED_OS"): Windows"

    $allPassed = $true

    # 检查 Node.js
    if (-not (Test-NodeVersion)) {
        $allPassed = $false
    }

    # 检查 openclaw
    if (-not (Test-OpenClawInstalled)) {
        $allPassed = $false
    }

    # 检查配置目录
    if (-not (Test-ConfigDir)) {
        $allPassed = $false
    }

    if (-not $allPassed) {
        Write-Error (Get-Message "ENV_CHECK_FAILED")
        exit 1
    }

    Write-Success (Get-Message "ENV_CHECK_PASSED")
}

# 询问用户输入 API Key
function Read-ApiKey {
    Write-Bold "`n=== $(Get-Message "CONFIG_API_KEY") ==="
    Write-Info (Get-Message "API_KEY_PROMPT")
    Write-Host ""

    while ($true) {
        $apiKey = Read-Host (Get-Message "ENTER_API_KEY")

        if ([string]::IsNullOrWhiteSpace($apiKey)) {
            Write-Error (Get-Message "API_KEY_EMPTY")
            continue
        }

        # 简单的格式检查
        if ($apiKey -notmatch '^[a-zA-Z0-9_-]+$') {
            Write-Warn (Get-Message "API_KEY_FORMAT_WARN")
            $confirm = Read-Host "$(Get-Message "API_KEY_CONFIRM") (y/N)"
            if ($confirm -notmatch '^[Yy]$') {
                continue
            }
        }

        break
    }

    $script:AinftApiKey = $apiKey
    Write-Success (Get-Message "API_KEY_RECEIVED")
}

# 从 API 获取模型列表
function Get-ModelsFromApi {
    Write-Info "$(Get-Message "FETCHING_MODELS")..."

    $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $script:AinftApiKey"
    }

    try {
        $response = Invoke-RestMethod -Uri $script:AinftModelsApi -Headers $headers -Method GET -ErrorAction Stop

        if (-not $response.data) {
            Write-Error (Get-Message "INVALID_RESPONSE_FORMAT")
            return $false
        }

        $script:AvailableModels = $response.data | ForEach-Object { $_.id }

        if ($script:AvailableModels.Count -eq 0) {
            Write-Error (Get-Message "NO_MODELS")
            return $false
        }

        Write-Success "$(Get-Message "MODELS_FETCHED") $($script:AvailableModels.Count) $(Get-Message "MODELS_COUNT")"
        return $true
    }
    catch [System.Net.WebException] {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Error "$(Get-Message "FETCH_MODELS_FAILED") (HTTP $statusCode)"

        if ($statusCode -eq 401) {
            Write-Info (Get-Message "HTTP_401_HINT")
        }
        return $false
    }
    catch {
        Write-Error "$(Get-Message "FETCH_MODELS_FAILED"): $($_.Exception.Message)"
        return $false
    }
}

# 选择默认模型
function Select-DefaultModel {
    Write-Bold "`n=== $(Get-Message "SELECT_DEFAULT_MODEL") ==="

    # 显示可用模型
    Write-Info "$(Get-Message "AVAILABLE_MODELS_LIST"):"
    for ($i = 0; $i -lt $script:AvailableModels.Count; $i++) {
        Write-Host "  $($i + 1)) $($script:AvailableModels[$i])"
    }

    Write-Host ""

    # 让用户手动选择
    while ($true) {
        $selection = Read-Host "$(Get-Message "ENTER_MODEL_NUMBER") (1-$($script:AvailableModels.Count))"

        if ($selection -match '^\d+$') {
            $index = [int]$selection - 1
            if ($index -ge 0 -and $index -lt $script:AvailableModels.Count) {
                $script:DefaultModel = $script:AvailableModels[$index]
                break
            }
        }
        Write-Error (Get-Message "INVALID_SELECTION")
    }

    Write-Success "$(Get-Message "DEFAULT_MODEL_SET"): $script:DefaultModel"
}

# 将模型列表转换为 JSON 格式
function Convert-ModelsToJson {
    $modelsArray = @()
    foreach ($model in $script:AvailableModels) {
        $modelsArray += @{ id = $model; name = $model }
    }
    return $modelsArray
}

# 更新配置文件
function Update-Config {
    Write-Bold "`n=== $(Get-Message "UPDATE_CONFIG") ==="

    # 备份原配置
    if (Test-Path $script:OpenClawConfigFile) {
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $backupFile = "$script:OpenClawConfigFile.backup.$timestamp"
        Copy-Item $script:OpenClawConfigFile $backupFile
        Write-Info "$(Get-Message "CONFIG_BACKUP"): $backupFile"
    }

    # 读取现有配置或创建新的
    $config = @{}
    if (Test-Path $script:OpenClawConfigFile) {
        try {
            $config = Get-Content $script:OpenClawConfigFile -Raw | ConvertFrom-Json -AsHashtable
        }
        catch {
            $config = @{}
        }
    }

    # 确保基本结构存在
    if (-not $config.models) {
        $config.models = @{}
    }
    if (-not $config.agents) {
        $config.agents = @{ defaults = @{ model = @{} } }
    }
    if (-not $config.agents.defaults) {
        $config.agents.defaults = @{ model = @{} }
    }
    if (-not $config.agents.defaults.model) {
        $config.agents.defaults.model = @{}
    }

    # 设置 AINFT Provider 配置
    $config.models.mode = "merge"
    $config.models.providers = @{
        ainft = @{
            baseUrl = $script:AinftBaseUrl
            apiKey = $script:AinftApiKey
            api = $script:AinftApi
            models = Convert-ModelsToJson
        }
    }

    # 设置默认模型
    $config.agents.defaults.model.primary = "ainft/$script:DefaultModel"

    # 写入文件
    $config | ConvertTo-Json -Depth 10 | Out-File $script:OpenClawConfigFile -Encoding UTF8

    Write-Success "$(Get-Message "CONFIG_UPDATED"): $script:OpenClawConfigFile"
}

# 重启 Gateway
function Restart-Gateway {
    Write-Bold "`n=== $(Get-Message "RESTART_GATEWAY") ==="

    if (-not (Test-Command "openclaw")) {
        Write-Error "$(Get-Message "OPENCLAW_NOT_FOUND")，$(Get-Message "GATEWAY_RESTART_FAILED")"
        return $false
    }

    Write-Info "$(Get-Message "GATEWAY_RESTARTING")..."
    try {
        openclaw gateway restart 2>$null
        Write-Success (Get-Message "GATEWAY_RESTART_SUCCESS")
        return $true
    }
    catch {
        Write-Error (Get-Message "GATEWAY_RESTART_FAILED")
        Write-Info "$(Get-Message "GATEWAY_MANUAL_RESTART"): openclaw gateway restart"
        return $false
    }
}

# 验证配置
function Test-Config {
    Write-Bold "`n=== $(Get-Message "VERIFY_CONFIG") ==="

    Write-Info "$(Get-Message "GATEWAY_STATUS_CHECK")..."
    try {
        $status = openclaw gateway status 2>$null
        Write-Success (Get-Message "GATEWAY_RUNNING")
    }
    catch {
        Write-Warn (Get-Message "GATEWAY_STATUS_FAILED")
    }

    Write-Info "$(Get-Message "TEST_COMMAND_HINT"):"
    Write-Info (Get-Message "TEST_COMMAND")
}

# 显示可用模型列表
function Show-AvailableModels {
    Write-Info "$(Get-Message "CONFIGURED_MODELS"):"
    foreach ($model in $script:AvailableModels) {
        if ($model -eq $script:DefaultModel) {
            Write-Host "  - ainft/$model ($(Get-Message "DEFAULT"))"
        }
        else {
            Write-Host "  - ainft/$model"
        }
    }
}

# 主函数
function Main {
    # 根据语言显示不同的标题
    if ($script:LangCode -eq "zh") {
        Write-Bold ""
        Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor White
        Write-Host "║          OpenClaw AINFT Provider 安装脚本                    ║" -ForegroundColor White
        Write-Host "║          支持 Windows PowerShell                             ║" -ForegroundColor White
        Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor White
        Write-Host ""
    }
    else {
        Write-Bold ""
        Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor White
        Write-Host "║          OpenClaw AINFT Provider Installation Script         ║" -ForegroundColor White
        Write-Host "║          Supports Windows PowerShell                         ║" -ForegroundColor White
        Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor White
        Write-Host ""
    }

    # 检查环境
    Test-Environment

    # 询问 API Key
    Read-ApiKey

    # 从 API 获取模型列表
    if (-not (Get-ModelsFromApi)) {
        Write-Error (Get-Message "CONFIG_ABORTED")
        exit 1
    }

    # 选择默认模型
    Select-DefaultModel

    # 更新配置
    Update-Config

    # 重启 Gateway
    Restart-Gateway | Out-Null

    # 验证配置
    Test-Config

    Write-Bold "`n=== $(Get-Message "INSTALL_COMPLETE") ==="
    Write-Success (Get-Message "CONFIG_SUCCESS")
    Write-Host ""
    Write-Info "$(Get-Message "DEFAULT_MODEL_LABEL"): ainft/$script:DefaultModel"
    Write-Info "$(Get-Message "CONFIG_FILE"): $script:OpenClawConfigFile"
    Write-Host ""
    Show-AvailableModels
    Write-Host ""
    Write-Info "$(Get-Message "SWITCH_MODEL_HINT") $script:OpenClawConfigFile"
    Write-Info "$(Get-Message "SWITCH_MODEL_CMD"): $(Get-Message "SWITCH_MODEL_CMD_EXAMPLE")"
}

# 运行主函数
Main
