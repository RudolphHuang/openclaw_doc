#Requires -Version 5.1
<#
.SYNOPSIS
    OpenClaw AINFT Provider Installation Script (Windows PowerShell)

.DESCRIPTION
    Automatically configure AINFT as OpenClaw model provider on Windows

.EXAMPLE
    iwr -useb https://chat.ainft.com/scripts/install-ainft-provider.ps1 | iex

    Or download and execute:
    .\install-ainft-provider.ps1
#>

[CmdletBinding()]
param()

# Error handling
$ErrorActionPreference = "Stop"

# Config paths
$script:OpenClawConfigDir = Join-Path $env:USERPROFILE ".openclaw"
$script:OpenClawConfigFile = Join-Path $script:OpenClawConfigDir "openclaw.json"

# AINFT Provider config
$script:AinftBaseUrl = "https://api.ainft.com/v1/"
$script:AinftApi = "openai-completions"
$script:AinftModelsApi = "https://api.ainft.com/v1/models"

# Store fetched models
$script:AvailableModels = @()
$script:DefaultModel = ""

# Message definitions
$script:Messages = @{
    INFO_PREFIX = "[INFO]"
    SUCCESS_PREFIX = "[SUCCESS]"
    WARN_PREFIX = "[WARN]"
    ERROR_PREFIX = "[ERROR]"

    CHECK_ENV = "Checking System Environment"
    DETECTED_OS = "Detected Operating System"
    ENV_CHECK_PASSED = "Environment check passed"
    ENV_CHECK_FAILED = "Environment check failed, please complete OpenClaw installation and initialization first"

    NODE_NOT_INSTALLED = "Node.js is not installed"
    NODE_INSTALL_PROMPT = "Please visit https://nodejs.org/ to install Node.js >= 22"
    NODE_VERSION_LOW = "Node.js version >= 22 is required, current version"
    NODE_VERSION_OK = "Node.js version check passed"
    NODE_UPGRADE = "Please upgrade Node.js"

    OPENCLAW_NOT_FOUND = "openclaw command not found"
    OPENCLAW_INSTALL_PROMPT = "Please install OpenClaw first"
    OPENCLAW_INSTALL_CMD = "  iwr -useb https://openclaw.ai/install.ps1 | iex"
    OPENCLAW_INSTALLED = "OpenClaw is installed"
    CONFIG_DIR_NOT_FOUND = "OpenClaw configuration directory does not exist"
    CONFIG_DIR_PROMPT = "Please run 'openclaw onboard' first to complete initialization"
    CONFIG_DIR_OK = "Configuration directory check passed"

    CONFIG_API_KEY = "Configuring AINFT API Key"
    API_KEY_PROMPT = "Please visit https://chat.ainft.com/key to apply for an API Key"
    ENTER_API_KEY = "Please enter your AINFT API Key"
    API_KEY_EMPTY = "API Key cannot be empty"
    API_KEY_FORMAT_WARN = "API Key format looks unusual, please verify"
    API_KEY_CONFIRM = "Continue with this API Key?"
    API_KEY_RECEIVED = "API Key received"

    FETCHING_MODELS = "Fetching available model list from AINFT API"
    FETCH_MODELS_FAILED = "Failed to fetch model list"
    HTTP_401_HINT = "Hint: HTTP 401 indicates authentication failure, please check if API Key is valid"
    INVALID_RESPONSE_FORMAT = "API returned invalid data format"
    NO_MODELS = "No models retrieved"
    MODELS_FETCHED = "Successfully fetched"
    MODELS_COUNT = "models"
    CONFIG_ABORTED = "Cannot fetch model list, configuration aborted"

    SELECT_DEFAULT_MODEL = "Select Default Model"
    AVAILABLE_MODELS_LIST = "Available Models"
    ENTER_MODEL_NUMBER = "Please enter model number"
    INVALID_SELECTION = "Invalid selection, please try again"
    DEFAULT_MODEL_SET = "Default model set to"

    UPDATE_CONFIG = "Updating OpenClaw Configuration File"
    CONFIG_BACKUP = "Original configuration backed up to"
    CONFIG_UPDATED = "Configuration file updated"
    CONFIG_FILE = "Configuration file"

    RESTART_GATEWAY = "Restarting OpenClaw Gateway"
    GATEWAY_RESTARTING = "Restarting Gateway..."
    GATEWAY_RESTART_SUCCESS = "Gateway restarted successfully"
    GATEWAY_RESTART_FAILED = "Gateway restart failed"
    GATEWAY_MANUAL_RESTART = "You can manually run"
    GATEWAY_STATUS_CHECK = "Checking Gateway status"
    GATEWAY_RUNNING = "Gateway is running normally"
    GATEWAY_STATUS_FAILED = "Gateway status check failed, please check manually"

    VERIFY_CONFIG = "Verifying Configuration"
    TEST_COMMAND_HINT = "Hint: You can run the following command to test the model"
    TEST_COMMAND = '  openclaw agent --agent main --message "Hello"'
    CONFIGURED_MODELS = "Configured Models"
    DEFAULT = "default"
    SWITCH_MODEL_HINT = "To switch models, please edit"
    SWITCH_MODEL_CMD = "Or use command"
    SWITCH_MODEL_CMD_EXAMPLE = "openclaw models set ainft/<model-name>"

    INSTALL_COMPLETE = "Installation Complete"
    CONFIG_SUCCESS = "AINFT Provider configured successfully!"
    DEFAULT_MODEL_LABEL = "Default Model"

    TITLE = "OpenClaw AINFT Provider Installation Script"
    SUPPORT = "Supports Windows PowerShell"
}

# Get message
function Get-Message($Key) {
    $msg = $script:Messages[$Key]
    if ($null -eq $msg) {
        return $Key
    }
    return $msg
}

# Color output functions
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

function WriteBold($Message) {
    Write-Host $Message -ForegroundColor White
}

# Run Node.js code for JSON processing
function Invoke-NodeJson($JsCode) {
    return node -e $JsCode
}

# Run Node.js code with stdin input
function Invoke-NodeJsonWithInput($JsCode, $InputData) {
    $InputData | node -e $JsCode
}

# Check if command exists
function Test-Command($Command) {
    return [bool](Get-Command -Name $Command -ErrorAction SilentlyContinue)
}

# Check Node.js version
function Test-NodeVersion {
    if (-not (Test-Command "node")) {
        Write-Error (Get-Message "NODE_NOT_INSTALLED")
        Write-Info (Get-Message "NODE_INSTALL_PROMPT")
        return $false
    }

    $nodeVersion = Invoke-NodeJson 'console.log(process.version.substring(1))'
    $majorVersion = [int](Invoke-NodeJson 'console.log(process.version.substring(1).split(String.fromCharCode(46))[0])')

    if ($majorVersion -lt 22) {
        Write-Error "$(Get-Message "NODE_VERSION_LOW"): $nodeVersion"
        Write-Info "$(Get-Message "NODE_UPGRADE"): https://nodejs.org/"
        return $false
    }

    Write-Success "$(Get-Message "NODE_VERSION_OK"): v$nodeVersion"
    return $true
}

# Check if openclaw is installed
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

# Check if config directory exists
function Test-ConfigDir {
    if (-not (Test-Path $script:OpenClawConfigDir -PathType Container)) {
        Write-Error "$(Get-Message "CONFIG_DIR_NOT_FOUND"): $script:OpenClawConfigDir"
        Write-Info (Get-Message "CONFIG_DIR_PROMPT")
        return $false
    }
    Write-Success "$(Get-Message "CONFIG_DIR_OK"): $script:OpenClawConfigDir"
    return $true
}

# Environment check
function Test-Environment {
    WriteBold "`n=== $(Get-Message "CHECK_ENV") ==="
    Write-Info "$(Get-Message "DETECTED_OS"): Windows"

    $allPassed = $true

    if (-not (Test-NodeVersion)) {
        $allPassed = $false
    }

    if (-not (Test-OpenClawInstalled)) {
        $allPassed = $false
    }

    if (-not (Test-ConfigDir)) {
        $allPassed = $false
    }

    if (-not $allPassed) {
        Write-Error (Get-Message "ENV_CHECK_FAILED")
        exit 1
    }

    Write-Success (Get-Message "ENV_CHECK_PASSED")
}

# Read API Key from user
function Read-ApiKey {
    WriteBold "`n=== $(Get-Message "CONFIG_API_KEY") ==="
    Write-Info (Get-Message "API_KEY_PROMPT")
    Write-Host ""

    while ($true) {
        $apiKey = Read-Host (Get-Message "ENTER_API_KEY")

        if ([string]::IsNullOrWhiteSpace($apiKey)) {
            Write-Error (Get-Message "API_KEY_EMPTY")
            continue
        }

        # Simple format check
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

# Fetch models from API using Node.js
function Get-ModelsFromApi {
    Write-Info "$(Get-Message "FETCHING_MODELS")..."

    $jsCode = @"
const https = require('https');
const options = {
    hostname: 'api.ainft.com',
    path: '/v1/models',
    method: 'GET',
    headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $script:AinftApiKey'
    }
};

const req = https.request(options, (res) => {
    let data = '';
    res.on('data', (chunk) => { data += chunk; });
    res.on('end', () => {
        try {
            const obj = JSON.parse(data);
            if (!obj.data || !Array.isArray(obj.data)) {
                console.error('INVALID_RESPONSE');
                process.exit(1);
            }
            console.log(JSON.stringify(obj.data.map(m => m.id)));
        } catch (e) {
            console.error('PARSE_ERROR');
            process.exit(1);
        }
    });
});

req.on('error', (e) => {
    console.error('REQUEST_ERROR');
    process.exit(1);
});

req.end();
"@

    try {
        $result = Invoke-NodeJson $jsCode 2>&1
        
        if ($result -match 'INVALID_RESPONSE|PARSE_ERROR|REQUEST_ERROR') {
            if ($result -match 'INVALID_RESPONSE|PARSE_ERROR') {
                Write-Error (Get-Message "INVALID_RESPONSE_FORMAT")
            } else {
                Write-Error (Get-Message "FETCH_MODELS_FAILED")
            }
            return $false
        }

        # Parse the JSON array from Node.js using stdin to avoid quoting issues
        $jsParseCode = @'
let data = '';
process.stdin.on('data', chunk => { data += chunk; });
process.stdin.on('end', () => {
    try {
        const arr = JSON.parse(data);
        console.log(arr.map(m => JSON.stringify(m)).join(String.fromCharCode(10)));
    } catch (e) {
        console.error('PARSE_ERROR:', e.message);
        process.exit(1);
    }
});
'@
        $modelsArray = Invoke-NodeJsonWithInput $jsParseCode $result
        
        # Parse each model name
        $jsParseLine = @'
let data = '';
process.stdin.on('data', chunk => { data += chunk; });
process.stdin.on('end', () => {
    data.split(String.fromCharCode(10)).forEach(line => {
        line = line.trim();
        if (line) {
            try {
                console.log(JSON.parse(line));
            } catch (e) {
                // skip invalid lines
            }
        }
    });
});
'@
        $script:AvailableModels = Invoke-NodeJsonWithInput $jsParseLine ($modelsArray -join "`n") -split "`n" | Where-Object { $_ }

        if ($script:AvailableModels.Count -eq 0) {
            Write-Error (Get-Message "NO_MODELS")
            return $false
        }

        Write-Success "$(Get-Message "MODELS_FETCHED") $($script:AvailableModels.Count) $(Get-Message "MODELS_COUNT")"
        return $true
    }
    catch {
        Write-Error "$(Get-Message "FETCH_MODELS_FAILED"): $($_.Exception.Message)"
        return $false
    }
}

# Select default model
function Select-DefaultModel {
    WriteBold "`n=== $(Get-Message "SELECT_DEFAULT_MODEL") ==="

    Write-Info "$(Get-Message "AVAILABLE_MODELS_LIST"):"
    for ($i = 0; $i -lt $script:AvailableModels.Count; $i++) {
        Write-Host "  $($i + 1)) $($script:AvailableModels[$i])"
    }

    Write-Host ""

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

# Convert models to JSON using Node.js
function Convert-ModelsToJson {
    $modelsJson = $script:AvailableModels | ConvertTo-Json
    $jsCode = @'
let data = '';
process.stdin.on('data', chunk => { data += chunk; });
process.stdin.on('end', () => {
    try {
        const models = JSON.parse(data);
        console.log(JSON.stringify(models.map(m => ({ id: m, name: m }))));
    } catch (e) {
        console.error('PARSE_ERROR:', e.message);
        process.exit(1);
    }
});
'@
    return Invoke-NodeJsonWithInput $jsCode ($modelsJson -join "`n")
}

# Update config file using Node.js
function Update-Config {
    WriteBold "`n=== $(Get-Message "UPDATE_CONFIG") ==="

    # Backup original config
    if (Test-Path $script:OpenClawConfigFile) {
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $backupFile = "$script:OpenClawConfigFile.backup.$timestamp"
        Copy-Item $script:OpenClawConfigFile $backupFile
        Write-Info "$(Get-Message "CONFIG_BACKUP"): $backupFile"
    }

    # Read existing config or use empty object
    $configContent = '{}'
    if (Test-Path $script:OpenClawConfigFile) {
        $configContent = Get-Content $script:OpenClawConfigFile -Raw -ErrorAction SilentlyContinue
        if ([string]::IsNullOrWhiteSpace($configContent)) {
            $configContent = '{}'
        }
    }

    # Build models JSON array
    $modelsJsonArray = Convert-ModelsToJson

    $configPath = $script:OpenClawConfigFile.Replace('\', '\\')
    $baseUrl = $script:AinftBaseUrl
    $apiKey = $script:AinftApiKey
    $api = $script:AinftApi
    $defaultModel = $script:DefaultModel
    
    $jsCode = @"
const fs = require('fs');
const path = '$configPath';
let config;
try {
    config = $configContent;
} catch (e) {
    config = {};
}
if (typeof config !== 'object' || config === null) config = {};
if (!config.models) config.models = {};
if (!config.models.providers) config.models.providers = {};
config.models.mode = 'merge';
config.models.providers.ainft = {
    baseUrl: '$baseUrl',
    apiKey: '$apiKey',
    api: '$api',
    models: $modelsJsonArray
};
if (!config.agents) config.agents = {};
if (!config.agents.defaults) config.agents.defaults = {};
if (!config.agents.defaults.model) config.agents.defaults.model = {};
config.agents.defaults.model.primary = 'ainft/$defaultModel';
fs.writeFileSync(path, JSON.stringify(config, null, 2));
console.log('Configuration updated successfully');
"@

    Invoke-NodeJson $jsCode | Out-Null

    Write-Success "$(Get-Message "CONFIG_UPDATED"): $script:OpenClawConfigFile"
}

# Restart Gateway
function Restart-Gateway {
    WriteBold "`n=== $(Get-Message "RESTART_GATEWAY") ==="

    if (-not (Test-Command "openclaw")) {
        Write-Error "$(Get-Message "OPENCLAW_NOT_FOUND"), $(Get-Message "GATEWAY_RESTART_FAILED")"
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

# Verify config
function Test-Config {
    WriteBold "`n=== $(Get-Message "VERIFY_CONFIG") ==="

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

# Show available models
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

# Main function
function Main {
    WriteBold ""
    Write-Host "==============================================================" -ForegroundColor White
    Write-Host "          OpenClaw AINFT Provider Installation Script         " -ForegroundColor White
    Write-Host "          Supports Windows PowerShell                         " -ForegroundColor White
    Write-Host "==============================================================" -ForegroundColor White
    Write-Host ""

    # Check environment
    Test-Environment

    # Read API Key
    Read-ApiKey

    # Fetch models from API
    if (-not (Get-ModelsFromApi)) {
        Write-Error (Get-Message "CONFIG_ABORTED")
        exit 1
    }

    # Select default model
    Select-DefaultModel

    # Update config
    Update-Config

    # Restart Gateway
    Restart-Gateway | Out-Null

    # Verify config
    Test-Config

    WriteBold "`n=== $(Get-Message "INSTALL_COMPLETE") ==="
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

# Run main function
Main
