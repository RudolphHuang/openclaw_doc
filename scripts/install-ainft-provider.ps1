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
$script:AinftBaseUrl = "https://chat.ainft.com/webapi/"
$script:AinftApi = "openai-completions"
$script:AinftModelsApi = "https://chat.ainft.com/v1/models"

# 存储获取到的模型列表
$script:AvailableModels = @()
$script:DefaultModel = ""

# 颜色定义
function Write-Info($Message) {
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success($Message) {
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warn($Message) {
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Error($Message) {
    Write-Host "[ERROR] $Message" -ForegroundColor Red
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
        Write-Error "Node.js 未安装"
        Write-Info "请前往 https://nodejs.org/ 安装 Node.js >= 22"
        return $false
    }
    
    $nodeVersion = (node -v) -replace 'v', ''
    $majorVersion = [int]($nodeVersion -split '\.')[0]
    
    if ($majorVersion -lt 22) {
        Write-Error "Node.js 版本需要 >= 22，当前版本: $nodeVersion"
        Write-Info "请升级 Node.js: https://nodejs.org/"
        return $false
    }
    
    Write-Success "Node.js 版本检查通过: v$nodeVersion"
    return $true
}

# 检查 openclaw 是否已安装
function Test-OpenClawInstalled {
    if (-not (Test-Command "openclaw")) {
        Write-Error "openclaw 命令未找到"
        Write-Info "请先安装 OpenClaw:"
        Write-Info "  iwr -useb https://openclaw.ai/install.ps1 | iex"
        return $false
    }
    
    try {
        $version = openclaw --version 2>$null
        if (-not $version) { $version = "unknown" }
    }
    catch {
        $version = "unknown"
    }
    
    Write-Success "OpenClaw 已安装: $version"
    return $true
}

# 检查配置文件目录是否存在
function Test-ConfigDir {
    if (-not (Test-Path $script:OpenClawConfigDir -PathType Container)) {
        Write-Error "OpenClaw 配置目录不存在: $script:OpenClawConfigDir"
        Write-Info "请先运行 'openclaw onboard' 完成初始化配置"
        return $false
    }
    Write-Success "配置目录检查通过: $script:OpenClawConfigDir"
    return $true
}

# 环境检查
function Test-Environment {
    Write-Bold "`n=== 检查系统环境 ==="
    Write-Info "检测到操作系统: Windows"
    
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
        Write-Error "环境检查未通过，请先完成 OpenClaw 的安装和初始化"
        exit 1
    }
    
    Write-Success "环境检查全部通过"
}

# 询问用户输入 API Key
function Read-ApiKey {
    Write-Bold "`n=== 配置 AINFT API Key ==="
    Write-Info "请前往 https://chat.ainft.com/key 申请 API Key"
    Write-Host ""
    
    while ($true) {
        $apiKey = Read-Host "请输入您的 AINFT API Key"
        
        if ([string]::IsNullOrWhiteSpace($apiKey)) {
            Write-Error "API Key 不能为空"
            continue
        }
        
        # 简单的格式检查
        if ($apiKey -notmatch '^[a-zA-Z0-9_-]+$') {
            Write-Warn "API Key 格式看起来不太常见，请确认是否正确"
            $confirm = Read-Host "是否继续使用此 API Key? (y/N)"
            if ($confirm -notmatch '^[Yy]$') {
                continue
            }
        }
        
        break
    }
    
    $script:AinftApiKey = $apiKey
    Write-Success "API Key 已接收"
}

# 从 API 获取模型列表
function Get-ModelsFromApi {
    Write-Info "正在从 AINFT API 获取可用模型列表..."
    
    $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $script:AinftApiKey"
    }
    
    try {
        $response = Invoke-RestMethod -Uri $script:AinftModelsApi -Headers $headers -Method GET -ErrorAction Stop
        
        if (-not $response.data) {
            Write-Error "API 返回数据格式异常"
            return $false
        }
        
        $script:AvailableModels = $response.data | ForEach-Object { $_.id }
        
        if ($script:AvailableModels.Count -eq 0) {
            Write-Error "未获取到任何模型"
            return $false
        }
        
        Write-Success "成功获取 $($script:AvailableModels.Count) 个模型"
        return $true
    }
    catch [System.Net.WebException] {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Error "获取模型列表失败 (HTTP $statusCode)"
        
        if ($statusCode -eq 401) {
            Write-Info "提示: HTTP 401 表示认证失败，请检查 API Key 是否有效"
        }
        return $false
    }
    catch {
        Write-Error "获取模型列表失败: $($_.Exception.Message)"
        return $false
    }
}

# 选择默认模型
function Select-DefaultModel {
    Write-Bold "`n=== 选择默认模型 ==="
    
    # 显示可用模型
    Write-Info "可用模型列表:"
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
    Write-Info "推荐默认模型: $recommended"
    
    # 询问用户是否使用推荐模型
    $useRecommended = Read-Host "是否使用推荐模型作为默认? (Y/n)"
    
    if ($useRecommended -notmatch '^[Nn]$') {
        $script:DefaultModel = $recommended
    }
    else {
        # 让用户手动选择
        while ($true) {
            $selection = Read-Host "请输入模型编号 (1-$($script:AvailableModels.Count))"
            
            if ($selection -match '^\d+$') {
                $index = [int]$selection - 1
                if ($index -ge 0 -and $index -lt $script:AvailableModels.Count) {
                    $script:DefaultModel = $script:AvailableModels[$index]
                    break
                }
            }
            Write-Error "无效的选择，请重新输入"
        }
    }
    
    Write-Success "默认模型设置为: $script:DefaultModel"
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
    Write-Bold "`n=== 更新 OpenClaw 配置文件 ==="
    
    # 备份原配置
    if (Test-Path $script:OpenClawConfigFile) {
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $backupFile = "$script:OpenClawConfigFile.backup.$timestamp"
        Copy-Item $script:OpenClawConfigFile $backupFile
        Write-Info "原配置已备份到: $backupFile"
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
    
    Write-Success "配置文件已更新: $script:OpenClawConfigFile"
}

# 重启 Gateway
function Restart-Gateway {
    Write-Bold "`n=== 重启 OpenClaw Gateway ==="
    
    if (-not (Test-Command "openclaw")) {
        Write-Error "openclaw 命令未找到，无法重启 Gateway"
        return $false
    }
    
    Write-Info "正在重启 Gateway..."
    try {
        openclaw gateway restart 2>$null
        Write-Success "Gateway 重启成功"
        return $true
    }
    catch {
        Write-Error "Gateway 重启失败"
        Write-Info "您可以手动运行: openclaw gateway restart"
        return $false
    }
}

# 验证配置
function Test-Config {
    Write-Bold "`n=== 验证配置 ==="
    
    Write-Info "检查 Gateway 状态..."
    try {
        $status = openclaw gateway status 2>$null
        Write-Success "Gateway 运行正常"
    }
    catch {
        Write-Warn "Gateway 状态检查失败，请手动检查"
    }
    
    Write-Info "提示: 您可以运行以下命令测试模型:"
    Write-Info '  openclaw agent --agent main --message "你好"'
}

# 显示可用模型列表
function Show-AvailableModels {
    Write-Info "已配置的模型:"
    foreach ($model in $script:AvailableModels) {
        if ($model -eq $script:DefaultModel) {
            Write-Host "  - ainft/$model (默认)"
        }
        else {
            Write-Host "  - ainft/$model"
        }
    }
}

# 主函数
function Main {
    Write-Bold ""
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor White
    Write-Host "║          OpenClaw AINFT Provider 安装脚本                    ║" -ForegroundColor White
    Write-Host "║          支持 Windows PowerShell                             ║" -ForegroundColor White
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor White
    Write-Host ""
    
    # 检查环境
    Test-Environment
    
    # 询问 API Key
    Read-ApiKey
    
    # 从 API 获取模型列表
    if (-not (Get-ModelsFromApi)) {
        Write-Error "无法获取模型列表，配置中止"
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
    
    Write-Bold "`n=== 安装完成 ==="
    Write-Success "AINFT Provider 配置成功！"
    Write-Host ""
    Write-Info "默认模型: ainft/$script:DefaultModel"
    Write-Info "配置文件: $script:OpenClawConfigFile"
    Write-Host ""
    Show-AvailableModels
    Write-Host ""
    Write-Info "如需切换模型，请编辑 $script:OpenClawConfigFile"
    Write-Info "或使用命令: openclaw models set ainft/<model-name>"
}

# 运行主函数
Main
