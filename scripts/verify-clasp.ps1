$ErrorActionPreference = "Stop"

function Write-Step {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Message
    )

    Write-Host ""
    Write-Host "==> $Message"
}

function Invoke-CheckedCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Command,

        [Parameter(Mandatory = $true)]
        [string[]] $Arguments
    )

    & $Command @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "Command failed: $Command $($Arguments -join ' ')"
    }
}

Write-Step "Checking Node.js"
Invoke-CheckedCommand -Command "node" -Arguments @("--version")

Write-Step "Checking npm"
Invoke-CheckedCommand -Command "npm" -Arguments @("--version")

Write-Step "Checking npx"
Invoke-CheckedCommand -Command "npx" -Arguments @("--version")

Write-Step "Checking @google/clasp availability"
Invoke-CheckedCommand -Command "npx" -Arguments @("-y", "@google/clasp", "--version")

Write-Step "Checking clasp authentication"
try {
    Invoke-CheckedCommand -Command "npx" -Arguments @("-y", "@google/clasp", "show-authorized-user", "--json")
}
catch {
    Write-Host ""
    Write-Host "clasp is installed, but authentication may be missing or invalid."
    Write-Host "Run: npx -y @google/clasp login"
    throw
}

Write-Host ""
Write-Host "Verification completed."
