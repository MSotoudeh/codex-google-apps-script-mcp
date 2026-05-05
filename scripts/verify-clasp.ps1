param(
    [switch] $Json
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Message
    )

    if (-not $Json) {
        Write-Host ""
        Write-Host "==> $Message"
    }
}

function Write-CheckResult {
    param(
        [Parameter(Mandatory = $true)]
        [pscustomobject] $Result
    )

    if ($Json) {
        return
    }

    if ($Result.Success) {
        if ($Result.Output) {
            Write-Host "OK: $($Result.Output)"
        }
        else {
            Write-Host "OK"
        }
        return
    }

    Write-Host "FAILED: $($Result.Error)"
    if ($Result.Guidance) {
        Write-Host $Result.Guidance
    }
}

function Invoke-Check {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Name,

        [Parameter(Mandatory = $true)]
        [string] $Command,

        [Parameter(Mandatory = $true)]
        [string[]] $Arguments,

        [Parameter(Mandatory = $true)]
        [string] $MissingGuidance,

        [Parameter(Mandatory = $true)]
        [string] $FailureGuidance
    )

    if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
        return [pscustomobject] @{
            name = $Name
            command = "$Command $($Arguments -join ' ')".Trim()
            success = $false
            exitCode = $null
            output = $null
            error = "$Command was not found on PATH."
            guidance = $MissingGuidance
        }
    }

    $output = & $Command @Arguments 2>&1
    $exitCode = $LASTEXITCODE
    $outputText = ($output | ForEach-Object { $_.ToString() }) -join "`n"

    if ($exitCode -eq 0) {
        return [pscustomobject] @{
            name = $Name
            command = "$Command $($Arguments -join ' ')".Trim()
            success = $true
            exitCode = $exitCode
            output = $outputText.Trim()
            error = $null
            guidance = $null
        }
    }

    return [pscustomobject] @{
        name = $Name
        command = "$Command $($Arguments -join ' ')".Trim()
        success = $false
        exitCode = $exitCode
        output = $outputText.Trim()
        error = "Command exited with code $exitCode."
        guidance = $FailureGuidance
    }
}

function Test-ClaspAuthentication {
    $result = Invoke-Check `
        -Name "clasp authentication" `
        -Command "npx" `
        -Arguments @("-y", "@google/clasp", "show-authorized-user", "--json") `
        -MissingGuidance "Install Node.js/npm and make sure npx is available on PATH." `
        -FailureGuidance "Unable to check clasp authentication. This can be caused by network/DNS errors, npx package execution problems, or clasp authentication state. Retry the command manually: npx -y @google/clasp show-authorized-user --json"

    if (-not $result.Success) {
        return $result
    }

    try {
        $auth = $result.Output | ConvertFrom-Json
    }
    catch {
        $result.success = $false
        $result.error = "clasp returned output that was not valid JSON."
        $result.guidance = "Retry manually with: npx -y @google/clasp show-authorized-user --json"
        return $result
    }

    if ($auth.loggedIn -ne $true) {
        $result.success = $false
        $result.error = "clasp is not authenticated."
        $result.guidance = "Run: npx -y @google/clasp login"
        return $result
    }

    if ($auth.email) {
        $result.output = "logged in as $($auth.email)"
    }

    return $result
}

$results = @()

Write-Step "Checking Node.js"
$results += Invoke-Check `
    -Name "Node.js" `
    -Command "node" `
    -Arguments @("--version") `
    -MissingGuidance "Install Node.js 20 or newer, then reopen PowerShell so PATH is refreshed." `
    -FailureGuidance "Node.js is installed but failed to run. Reinstall Node.js or check your PATH."
Write-CheckResult $results[-1]

Write-Step "Checking npm"
$results += Invoke-Check `
    -Name "npm" `
    -Command "npm" `
    -Arguments @("--version") `
    -MissingGuidance "Install Node.js with npm included, then reopen PowerShell so PATH is refreshed." `
    -FailureGuidance "npm is installed but failed to run. Reinstall Node.js/npm or check your PATH."
Write-CheckResult $results[-1]

Write-Step "Checking npx"
$results += Invoke-Check `
    -Name "npx" `
    -Command "npx" `
    -Arguments @("--version") `
    -MissingGuidance "Install Node.js with npm/npx included, then reopen PowerShell so PATH is refreshed." `
    -FailureGuidance "npx is installed but failed to run. Reinstall Node.js/npm or check your PATH."
Write-CheckResult $results[-1]

Write-Step "Checking @google/clasp availability"
$results += Invoke-Check `
    -Name "@google/clasp" `
    -Command "npx" `
    -Arguments @("-y", "@google/clasp", "--version") `
    -MissingGuidance "Install Node.js/npm and make sure npx is available on PATH." `
    -FailureGuidance "npx could not execute @google/clasp. Check your network connection, npm registry access, and Node.js installation."
Write-CheckResult $results[-1]

Write-Step "Checking clasp authentication"
$results += Test-ClaspAuthentication
Write-CheckResult $results[-1]

$success = -not ($results | Where-Object { -not $_.success })

if ($Json) {
    [pscustomobject] @{
        success = $success
        checks = $results
    } | ConvertTo-Json -Depth 5
}
elseif ($success) {
    Write-Host ""
    Write-Host "Verification completed."
}
else {
    Write-Host ""
    Write-Host "Verification failed. Fix the failed check above and rerun this script."
}

if (-not $success) {
    exit 1
}
