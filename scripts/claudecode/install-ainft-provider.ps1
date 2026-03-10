#Requires -Version 5.1
<#
.SYNOPSIS
    Claude Code AINFT Provider 安装脚本 (Windows PowerShell)

.DESCRIPTION
    用于在 Windows 上自动配置 AINFT 作为 Claude Code 的模型提供商

.EXAMPLE
    iwr -useb https://chat.ainft.com/scripts/install-ainft-provider-claude.ps1 | iex

    或者下载后执行:
    .\install-ainft-provider.ps1
#>

[CmdletBinding()]
param()

# 错误处理
$ErrorActionPreference = "Stop"

# 配置路径
$script:ShellProfile = $PROFILE

# AINFT Provider 配置
$script:AinftBaseUrl = "https://api.ainft.com/"
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

    # 标题
    TITLE = @("Claude Code AINFT Provider 安装脚本", "Claude Code AINFT Provider Installation Script")
    SUPPORT = @("支持 Windows PowerShell", "Supports Windows PowerShell")

    # 环境检查
    CHECK_ENV = @("检查系统环境", "Checking System Environment")
    DETECTED_OS = @("检测到操作系统", "Detected Operating System")
    ENV_CHECK_PASSED = @("环境检查全部通过", "Environment check passed")
    ENV_CHECK_FAILED = @("环境检查未通过，请先完成 Claude Code 的安装", "Environment check failed, please complete Claude Code installation first")

    # Claude Code 相关
    CLAUDE_NOT_FOUND = @("claude 命令未找到", "claude command not found")
    CLAUDE_INSTALL_PROMPT = @("请先安装 Claude Code", "Please install Claude Code first")
    CLAUDE_INSTALL_CMD = @("  iwr -useb https://claude.ai/install.ps1 | iex", "  iwr -useb https://claude.ai/install.ps1 | iex")
    CLAUDE_INSTALLED = @("Claude Code 已安装", "Claude Code is installed")

    # API Token
    CONFIG_API_TOKEN = @("配置 AINFT API Token", "Configuring AINFT API Token")
    API_TOKEN_PROMPT = @("请前往 https://chat.ainft.com/key 申请 API Token", "Please visit https://chat.ainft.com/key to apply for an API Token")
    ENTER_API_TOKEN = @("请输入您的 AINFT API Token", "Please enter your AINFT API Token")
    API_TOKEN_EMPTY = @("API Token 不能为空", "API Token cannot be empty")
    API_TOKEN_FORMAT_WARN = @("API Token 格式看起来不太常见，请确认是否正确", "API Token format looks unusual, please verify")
    API_TOKEN_CONFIRM = @("是否继续使用此 API Token?", "Continue with this API Token?")
    API_TOKEN_RECEIVED = @("API Token 已接收", "API Token received")

    # 模型相关
    FETCHING_MODELS = @("正在从 AINFT API 获取可用模型列表", "Fetching available model list from AINFT API")
    FETCH_MODELS_FAILED = @("获取模型列表失败", "Failed to fetch model list")
    HTTP_401_HINT = @("提示: HTTP 401 表示认证失败，请检查 API Token 是否有效", "Hint: HTTP 401 indicates authentication failure, please check if API Token is valid")
    INVALID_RESPONSE_FORMAT = @("API 返回数据格式异常", "API returned invalid data format")
    NO_MODELS = @("未获取到任何模型", "No models retrieved")
    MODELS_FETCHED = @("成功获取", "Successfully fetched")
    MODELS_COUNT = @("个模型", "models")
    CONFIG_ABORTED = @("无法获取模型列表，配置中止", "Cannot fetch model list, configuration aborted")

    # 选择模型
    SELECT_DEFAULT_MODEL = @("选择默认模型", "Select Default Model")
    AVAILABLE_MODELS_LIST = @("可用模型列表", "Available Models")
    RECOMMENDED_MODEL = @("推荐默认模型", "Recommended default model")
    USE_RECOMMENDED = @("是否使用推荐模型作为默认?", "Use recommended model as default?")
    ENTER_MODEL_NUMBER = @("请输入模型编号", "Please enter model number")
    INVALID_SELECTION = @("无效的选择，请重新输入", "Invalid selection, please try again")
    DEFAULT_MODEL_SET = @("默认模型设置为", "Default model set to")

    # 配置文件
    UPDATE_CONFIG = @("更新 PowerShell 配置文件", "Updating PowerShell Profile")
    CONFIG_BACKUP = @("原配置已备份到", "Original configuration backed up to")
    CONFIG_UPDATED = @("配置文件已更新", "Configuration file updated")
    PROFILE_FILE = @("配置文件", "Profile file")
    RELOAD_CONFIG = @("重新加载配置文件", "Reloading configuration file")
    RELOAD_CONFIG_HINT = @("请运行以下命令使配置生效", "Please run the following command to apply the configuration")

    # 验证和测试
    VERIFY_CONFIG = @("验证配置", "Verifying Configuration")
    TEST_COMMAND_HINT = @("提示: 您可以运行以下命令启动 Claude Code 进行测试", "Hint: You can run the following command to start Claude Code for testing")
    TEST_COMMAND = @("  claude", "  claude")
    CONFIGURED_MODELS = @("已配置的模型", "Configured Models")
    DEFAULT = @("默认", "default")
    ENV_SET = @("环境变量已设置", "Environment variables set")

    # 完成
    INSTALL_COMPLETE = @("安装完成", "Installation Complete")
    CONFIG_SUCCESS = @("AINFT Provider 配置成功！", "AINFT Provider configured successfully!")
    DEFAULT_MODEL_LABEL = @("默认模型", "Default Model")
    BASE_URL_LABEL = @("API 基础地址", "API Base URL")
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

# 检查 Claude Code 是否已安装
function Test-ClaudeInstalled {
    if (-not (Test-Command "claude")) {
        Write-Error (Get-Message "CLAUDE_NOT_FOUND")
        Write-Info (Get-Message "CLAUDE_INSTALL_PROMPT")
        Write-Info (Get-Message "CLAUDE_INSTALL_CMD")
        return $false
    }

    try {
        $version = claude --version 2>$null
        if (-not $version) { $version = "unknown" }
    }
    catch {
        $version = "unknown"
    }

    Write-Success "$(Get-Message "CLAUDE_INSTALLED"): $version"
    return $true
}

# 环境检查
function Test-Environment {
    Write-Bold "`n=== $(Get-Message "CHECK_ENV") ==="
    Write-Info "$(Get-Message "DETECTED_OS"): Windows"

    $allPassed = $true

    # 检查 claude
    if (-not (Test-ClaudeInstalled)) {
        $allPassed = $false
    }

    if (-not $allPassed) {
        Write-Error (Get-Message "ENV_CHECK_FAILED")
        exit 1
    }

    Write-Success (Get-Message "ENV_CHECK_PASSED")
}

# 询问用户输入 API Token
function Read-ApiToken {
    Write-Bold "`n=== $(Get-Message "CONFIG_API_TOKEN") ==="
    Write-Info (Get-Message "API_TOKEN_PROMPT")
    Write-Host ""

    while ($true) {
        $apiToken = Read-Host (Get-Message "ENTER_API_TOKEN")

        if ([string]::IsNullOrWhiteSpace($apiToken)) {
            Write-Error (Get-Message "API_TOKEN_EMPTY")
            continue
        }

        # 简单的格式检查
        if ($apiToken -notmatch '^[a-zA-Z0-9_-]+$') {
            Write-Warn (Get-Message "API_TOKEN_FORMAT_WARN")
            $confirm = Read-Host "$(Get-Message "API_TOKEN_CONFIRM") (y/N)"
            if ($confirm -notmatch '^[Yy]$') {
                continue
            }
        }

        break
    }

    $script:AinftApiToken = $apiToken
    Write-Success (Get-Message "API_TOKEN_RECEIVED")
}

# 从 API 获取模型列表
function Get-ModelsFromApi {
    Write-Info "$(Get-Message "FETCHING_MODELS")..."

    $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $script:AinftApiToken"
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

    # 推荐优先级：gpt-5-nano > gpt-5-mini > 第一个可用模型
    $recommended = ""
    if ($script:AvailableModels -contains "gpt-5-nano") {
        $recommended = "gpt-5-nano"
    }
    elseif ($script:AvailableModels -contains "gpt-5-mini") {
        $recommended = "gpt-5-mini"
    }
    else {
        $recommended = $script:AvailableModels[0]
    }

    Write-Host ""
    Write-Info "$(Get-Message "RECOMMENDED_MODEL"): $recommended"

    # 询问用户是否使用推荐模型
    $useRecommended = Read-Host "$(Get-Message "USE_RECOMMENDED") (Y/n)"

    if ($useRecommended -notmatch '^[Nn]$') {
        $script:DefaultModel = $recommended
    }
    else {
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
    }

    Write-Success "$(Get-Message "DEFAULT_MODEL_SET"): $script:DefaultModel"
}

# 更新 PowerShell 配置文件
function Update-Profile {
    Write-Bold "`n=== $(Get-Message "UPDATE_CONFIG") ==="

    # 确保配置文件存在
    if (-not (Test-Path $script:ShellProfile)) {
        $profileDir = Split-Path -Parent $script:ShellProfile
        if (-not (Test-Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        }
        New-Item -ItemType File -Path $script:ShellProfile -Force | Out-Null
    }

    # 备份原配置
    if (Test-Path $script:ShellProfile) {
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $backupFile = "$script:ShellProfile.backup.$timestamp"
        Copy-Item $script:ShellProfile $backupFile
        Write-Info "$(Get-Message "CONFIG_BACKUP"): $backupFile"
    }

    # 读取现有配置
    $profileContent = Get-Content $script:ShellProfile -Raw -ErrorAction SilentlyContinue
    if (-not $profileContent) { $profileContent = "" }

    # 移除旧的 AINFT 配置
    $profileContent = $profileContent -replace "`r?`n# Claude Code - AINFT Provider Configuration[\s\S]*?# End of AINFT Provider Configuration", ""
    # 移除旧的单独环境变量设置
    $profileContent = $profileContent -replace "`r?`n\s*\$env:ANTHROPIC_BASE_URL\s*=.*", ""
    $profileContent = $profileContent -replace "`r?`n\s*\$env:ANTHROPIC_AUTH_TOKEN\s*=.*", ""
    $profileContent = $profileContent -replace "`r?`n\s*\$env:ANTHROPIC_MODEL\s*=.*", ""

    # 添加新的配置
    $newConfig = @"

# Claude Code - AINFT Provider Configuration
`$env:ANTHROPIC_BASE_URL = "$script:AinftBaseUrl"
`$env:ANTHROPIC_AUTH_TOKEN = "$script:AinftApiToken"
`$env:ANTHROPIC_MODEL = "$script:DefaultModel"
# End of AINFT Provider Configuration
"@

    $profileContent + $newConfig | Out-File $script:ShellProfile -Encoding UTF8

    Write-Success "$(Get-Message "CONFIG_UPDATED"): $script:ShellProfile"
}

# 验证配置
function Test-Config {
    Write-Bold "`n=== $(Get-Message "VERIFY_CONFIG") ==="

    Write-Info "$(Get-Message "ENV_SET"):"
    Write-Host "  ANTHROPIC_BASE_URL=$script:AinftBaseUrl"
    Write-Host "  ANTHROPIC_AUTH_TOKEN=********" # 隐藏实际的 token
    Write-Host "  ANTHROPIC_MODEL=$script:DefaultModel"

    Write-Host ""
    Write-Info "$(Get-Message "RELOAD_CONFIG_HINT"):"
    Write-Host "  . `$PROFILE"

    Write-Host ""
    Write-Info "$(Get-Message "TEST_COMMAND_HINT"):"
    Write-Info (Get-Message "TEST_COMMAND")
}

# 显示可用模型列表
function Show-AvailableModels {
    Write-Info "$(Get-Message "CONFIGURED_MODELS"):"
    foreach ($model in $script:AvailableModels) {
        if ($model -eq $script:DefaultModel) {
            Write-Host "  - $model ($(Get-Message "DEFAULT"))"
        }
        else {
            Write-Host "  - $model"
        }
    }
}

# 主函数
function Main {
    # 根据语言显示不同的标题
    if ($script:LangCode -eq "zh") {
        Write-Bold ""
        Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor White
        Write-Host "║          Claude Code AINFT Provider 安装脚本                 ║" -ForegroundColor White
        Write-Host "║          支持 Windows PowerShell                             ║" -ForegroundColor White
        Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor White
        Write-Host ""
    }
    else {
        Write-Bold ""
        Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor White
        Write-Host "║          Claude Code AINFT Provider Installation Script      ║" -ForegroundColor White
        Write-Host "║          Supports Windows PowerShell                         ║" -ForegroundColor White
        Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor White
        Write-Host ""
    }

    # 检查环境
    Test-Environment

    # 询问 API Token
    Read-ApiToken

    # 从 API 获取模型列表
    if (-not (Get-ModelsFromApi)) {
        # 如果获取失败，使用默认模型列表
        Write-Warn "$(Get-Message "FETCH_MODELS_FAILED")，使用默认模型列表"
        $script:AvailableModels = @("gpt-5-nano", "gpt-5-mini", "gpt-5")
        $script:DefaultModel = "gpt-5-nano"
    }

    # 选择默认模型
    if ($script:AvailableModels.Count -gt 0) {
        Select-DefaultModel
    }

    # 更新配置
    Update-Profile

    # 验证配置
    Test-Config

    Write-Bold "`n=== $(Get-Message "INSTALL_COMPLETE") ==="
    Write-Success (Get-Message "CONFIG_SUCCESS")
    Write-Host ""
    Write-Info "$(Get-Message "DEFAULT_MODEL_LABEL"): $script:DefaultModel"
    Write-Info "$(Get-Message "BASE_URL_LABEL"): $script:AinftBaseUrl"
    Write-Info "$(Get-Message "PROFILE_FILE"): $script:ShellProfile"
    Write-Host ""
    Show-AvailableModels
}

# 运行主函数
Main
