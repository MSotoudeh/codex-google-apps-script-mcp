param(
    [string] $WorkspacePath = (Get-Location).Path,
    [switch] $SkipLogin,
    [switch] $NoBrowser
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([Parameter(Mandatory = $true)][string] $Message)
    Write-Host ""
    Write-Host "==> $Message"
}

function Assert-Command {
    param([Parameter(Mandatory = $true)][string] $Name)

    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) {
        throw "Required command not found: $Name"
    }

    return $cmd.Source
}

function Invoke-CheckedCommand {
    param(
        [Parameter(Mandatory = $true)][string] $Command,
        [Parameter(Mandatory = $true)][string[]] $Arguments
    )

    & $Command @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "Command failed: $Command $($Arguments -join ' ')"
    }
}

function Set-ClaspMcpConfig {
    param([Parameter(Mandatory = $true)][string] $TargetPath)

    if (-not (Test-Path $TargetPath)) {
        New-Item -ItemType Directory -Force -Path $TargetPath | Out-Null
    }

    $mcpPath = Join-Path $TargetPath ".mcp.json"

    if (Test-Path $mcpPath) {
        $raw = Get-Content -Raw -Path $mcpPath
        if ([string]::IsNullOrWhiteSpace($raw)) {
            $config = [ordered]@{}
        }
        else {
            $config = $raw | ConvertFrom-Json
        }
    }
    else {
        $config = [ordered]@{}
    }

    if (-not ($config.PSObject.Properties.Name -contains "mcpServers")) {
        $config | Add-Member -MemberType NoteProperty -Name "mcpServers" -Value ([ordered]@{})
    }

    $mcpServers = $config.mcpServers

    if ($mcpServers.PSObject.Properties.Name -contains "clasp") {
        $mcpServers.PSObject.Properties.Remove("clasp")
    }

    $claspServer = [ordered]@{
        command = "npx"
        args = @("-y", "@google/clasp", "mcp")
    }

    $mcpServers | Add-Member -MemberType NoteProperty -Name "clasp" -Value $claspServer

    $config | ConvertTo-Json -Depth 20 | Set-Content -Path $mcpPath -Encoding UTF8

    return $mcpPath
}

Write-Host "Codex + Google Apps Script clasp MCP installer"
Write-Host "Target workspace: $WorkspacePath"

Write-Step "Checking required local tools"
$nodePath = Assert-Command "node"
$npmPath = Assert-Command "npm"
$npxPath = Assert-Command "npx"

Write-Host "node: $nodePath"
Write-Host "npm:  $npmPath"
Write-Host "npx:  $npxPath"

Write-Step "Checking versions"
Invoke-CheckedCommand -Command "node" -Arguments @("--version")
Invoke-CheckedCommand -Command "npm" -Arguments @("--version")
Invoke-CheckedCommand -Command "npx" -Arguments @("--version")

Write-Step "Checking @google/clasp"
Invoke-CheckedCommand -Command "npx" -Arguments @("-y", "@google/clasp", "--version")

if (-not $NoBrowser) {
    Write-Step "Opening Apps Script API settings page"
    Start-Process "https://script.google.com/home/usersettings"
    Write-Host "Enable the Apps Script API for the Google account you will use with clasp."
}
else {
    Write-Step "Apps Script API settings"
    Write-Host "Open this URL and enable the Apps Script API:"
    Write-Host "https://script.google.com/home/usersettings"
}

if (-not $SkipLogin) {
    Write-Step "Checking clasp authentication"
    $authOk = $false

    try {
        & npx -y @google/clasp show-authorized-user --json
        if ($LASTEXITCODE -eq 0) {
            $authOk = $true
        }
    }
    catch {
        $authOk = $false
    }

    if (-not $authOk) {
        Write-Host "clasp is not authenticated. Starting login flow..."
        Invoke-CheckedCommand -Command "npx" -Arguments @("-y", "@google/clasp", "login")
    }

    Write-Step "Verifying clasp authentication"
    Invoke-CheckedCommand -Command "npx" -Arguments @("-y", "@google/clasp", "show-authorized-user", "--json")
}
else {
    Write-Step "Skipping clasp login because -SkipLogin was provided"
}

Write-Step "Creating or updating Codex MCP config"
$mcpPath = Set-ClaspMcpConfig -TargetPath $WorkspacePath
Write-Host "Updated: $mcpPath"

Write-Host ""
Write-Host "Install completed."
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Restart Codex."
Write-Host "2. Open this workspace in Codex: $WorkspacePath"
Write-Host "3. Ask Codex: List the available MCP tools from the clasp server. Do not modify any files or Google projects."
