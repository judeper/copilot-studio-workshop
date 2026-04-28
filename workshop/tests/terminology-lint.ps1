<#
.SYNOPSIS
  Terminology lint for the Copilot Studio for Financial Services workshop.

.DESCRIPTION
  Greps every Markdown file under workshop/ (and the repo README.md) for forbidden
  tokens that should not appear in current participant- or facilitator-facing
  content. Prints a report and returns a non-zero exit code if any forbidden
  token is found, so this script can be used as a CI gate for atomic merges of
  P0 correctness sweeps (Plan v2, Pass 1).

  Rules are designed to be precise — only patterns that are unambiguously wrong
  in the current Copilot Studio (April 2026) GA story are flagged. Generic
  English words like "messages" are NOT flagged on their own; only billing-style
  phrases ("message capacity", "message pack", "messages per user", ...).

.PARAMETER Root
  Repository root. Defaults to two levels up from this script.

.PARAMETER ExcludePath
  Additional path globs to skip. Useful while research artifacts or the
  PowerCAT review folder are still on disk.

.EXAMPLE
  pwsh -File workshop/tests/terminology-lint.ps1

.EXAMPLE
  pwsh -File workshop/tests/terminology-lint.ps1 -ExcludePath 'review','research'

.NOTES
  Add new rules to $script:Rules below. Each rule is a hashtable with:
    Pattern    : a regex (case-insensitive unless overridden)
    Reason     : short explanation shown in the report
    Severity   : 'error' (fails CI) or 'warn' (printed but non-blocking)
    AllowFiles : optional array of relative-path globs where the pattern is OK
                 (e.g., historical references)
#>

[CmdletBinding()]
param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path,
    [string[]]$ExcludePath = @('review', 'research', 'workshop\research', 'workshop\pdf-output', 'node_modules', '.git')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Rule definitions
# ---------------------------------------------------------------------------

$script:Rules = @(
    @{
        Name     = 'PVA-product-name'
        Pattern  = '\bPower Virtual Agents\b'
        Reason   = 'Use "Microsoft Copilot Studio". "Power Virtual Agents" is the deprecated product name.'
        Severity = 'error'
        AllowFiles = @(
            # Historical-context callouts may keep "formerly Power Virtual Agents" — flag for review only.
        )
    },
    @{
        Name     = 'PVA-abbrev'
        Pattern  = '\bPVA\b'
        Reason   = 'Use "Microsoft Copilot Studio" instead of the "PVA" abbreviation.'
        Severity = 'error'
        AllowFiles = @()
    },
    @{
        Name     = 'message-capacity'
        Pattern  = '\bmessage capacit(y|ies)\b'
        Reason   = 'Billing model is now Copilot Credits. Replace "message capacity" with "Copilot Credits".'
        Severity = 'error'
        AllowFiles = @()
    },
    @{
        Name     = 'message-pack'
        Pattern  = '\bmessage pack(s)?\b'
        Reason   = 'Billing model is now Copilot Credits. Replace "message pack" with "Copilot Credits".'
        Severity = 'error'
        AllowFiles = @()
    },
    @{
        Name     = 'messages-per-user'
        Pattern  = '\bmessages per (user|tenant|month)\b'
        Reason   = 'Billing model is now Copilot Credits. Reword in terms of Copilot Credits.'
        Severity = 'error'
        AllowFiles = @()
    },
    @{
        Name     = 'tenant-messages'
        Pattern  = '\btenant message(s)?\b'
        Reason   = 'Billing model is now Copilot Credits. Replace "tenant messages" with "tenant Copilot Credits".'
        Severity = 'error'
        AllowFiles = @()
    },
    @{
        Name     = 'additional-messages'
        Pattern  = '\badditional message(s)?\b'
        Reason   = 'Billing model is now Copilot Credits. Reword in terms of Copilot Credits.'
        Severity = 'error'
        AllowFiles = @()
    },
    @{
        # Flags positive claims like "powered by o3" but allows disambiguation like "(not o3)".
        Name     = 'o3-model'
        Pattern  = '(?<!not )(?<!NOT )\b(OpenAI )?o3\b(?! disambiguation)'
        Reason   = 'Deep Reasoning is OpenAI o1-based (GA Mar 2025). There is no "o3" in Copilot Studio. (Use "not o3" for explicit disambiguation.)'
        Severity = 'error'
        AllowFiles = @()
    },
    @{
        Name     = 'sse-transport'
        Pattern  = '\b(SSE|Server-Sent Events) transport\b'
        Reason   = 'SSE MCP transport is deprecated for new servers. Use Streamable HTTP.'
        Severity = 'error'
        AllowFiles = @()
    },
    @{
        Name     = 'three-zones-as-msft'
        Pattern  = '(Microsoft|Microsoft''s|official) (Three[- ]Zone|Three Zones?)( governance| framework| pattern)?'
        Reason   = '"Three Zones" is a PowerCAT teaching pattern, not a Microsoft official framework. Label it as such.'
        Severity = 'error'
        AllowFiles = @()
        # Lines containing any of these tokens are explicitly disambiguating the term, not asserting it.
        AllowLineContains = @('PowerCAT', 'not a Microsoft', 'not Microsoft', 'find nothing', "doesn't exist", 'is not an official')
    },
    @{
        # Targets claims that GPT-5 itself is not yet GA. Allows "GPT-5 Reasoning (Preview)" sibling-model phrasing.
        Name     = 'gpt5-future-ga'
        Pattern  = '\bGPT-?5\b(?! (Reasoning|Auto|mini|Chat))[^.]{0,60}\b(coming soon|will be GA|GA in 2026|not yet GA)\b'
        Reason   = 'GPT-5 in the Copilot Studio model picker has been GA since August 7, 2025.'
        Severity = 'warn'
        AllowFiles = @()
    },
    @{
        Name     = 'computer-use-may-2026'
        Pattern  = 'Computer Use.{0,40}May 2026'
        Reason   = 'Computer Use targets H1 CY2026 (May–June). Avoid stating "May 2026" as fact.'
        Severity = 'warn'
        AllowFiles = @()
    },
    @{
        Name     = 'sharepoint-lists-ga'
        Pattern  = 'SharePoint Lists.{0,40}\b(GA|generally available)\b'
        Reason   = 'SharePoint Lists as a knowledge source is planned (Wave 1 2026), not GA.'
        Severity = 'warn'
        AllowFiles = @()
    }
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

function Test-PathExcluded {
    param([string]$RelativePath, [string[]]$Excludes)
    foreach ($ex in $Excludes) {
        $normalized = $ex.Replace('/', '\').TrimEnd('\')
        if ($RelativePath -like "$normalized*" -or $RelativePath -like "*\$normalized\*") {
            return $true
        }
    }
    return $false
}

function Test-FileAllowed {
    param([string]$RelativePath, [string[]]$AllowGlobs)
    if (-not $AllowGlobs -or $AllowGlobs.Count -eq 0) { return $false }
    foreach ($glob in $AllowGlobs) {
        if ($RelativePath -like $glob) { return $true }
    }
    return $false
}

function Get-LineMatches {
    param([string]$Path, [string]$Pattern, [string[]]$AllowLineContains)
    $results = @()
    $i = 0
    foreach ($line in (Get-Content -LiteralPath $Path)) {
        $i++
        if ($line -match $Pattern) {
            if ($AllowLineContains -and $AllowLineContains.Count -gt 0) {
                $skip = $false
                foreach ($token in $AllowLineContains) {
                    if ($line -like "*$token*") { $skip = $true; break }
                }
                if ($skip) { continue }
            }
            $results += [PSCustomObject]@{
                LineNumber = $i
                Line       = $line.Trim()
            }
        }
    }
    return $results
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

Write-Host "Terminology lint — root: $Root" -ForegroundColor Cyan
Write-Host "Excluding: $($ExcludePath -join ', ')" -ForegroundColor DarkGray
Write-Host ""

$markdownFiles = Get-ChildItem -Path $Root -Filter '*.md' -Recurse -File |
    Where-Object {
        $rel = [System.IO.Path]::GetRelativePath($Root, $_.FullName)
        -not (Test-PathExcluded -RelativePath $rel -Excludes $ExcludePath)
    }

Write-Host "Scanning $($markdownFiles.Count) markdown files..." -ForegroundColor DarkGray
Write-Host ""

$errorCount = 0
$warnCount  = 0
$findings   = @()

foreach ($file in $markdownFiles) {
    $rel = [System.IO.Path]::GetRelativePath($Root, $file.FullName)
    foreach ($rule in $script:Rules) {
        if (Test-FileAllowed -RelativePath $rel -AllowGlobs $rule.AllowFiles) { continue }
        $allowLine = if ($rule.ContainsKey('AllowLineContains')) { $rule.AllowLineContains } else { @() }
        $hits = Get-LineMatches -Path $file.FullName -Pattern $rule.Pattern -AllowLineContains $allowLine
        foreach ($hit in $hits) {
            $findings += [PSCustomObject]@{
                File       = $rel
                LineNumber = $hit.LineNumber
                Rule       = $rule.Name
                Severity   = $rule.Severity
                Reason     = $rule.Reason
                Snippet    = $hit.Line
            }
            if ($rule.Severity -eq 'error') { $errorCount++ } else { $warnCount++ }
        }
    }
}

if ($findings.Count -eq 0) {
    Write-Host "PASS — no forbidden terminology found." -ForegroundColor Green
    exit 0
}

# Group output by file
$grouped = $findings | Group-Object File | Sort-Object Name
foreach ($group in $grouped) {
    Write-Host $group.Name -ForegroundColor Yellow
    foreach ($f in ($group.Group | Sort-Object LineNumber)) {
        $color = if ($f.Severity -eq 'error') { 'Red' } else { 'DarkYellow' }
        Write-Host ("  L{0,4} [{1}] {2}" -f $f.LineNumber, $f.Severity.ToUpper(), $f.Rule) -ForegroundColor $color
        Write-Host ("        {0}" -f $f.Reason) -ForegroundColor DarkGray
        Write-Host ("        > {0}" -f $f.Snippet) -ForegroundColor DarkGray
    }
    Write-Host ""
}

Write-Host ("Summary: {0} error(s), {1} warning(s) across {2} file(s)." -f $errorCount, $warnCount, $grouped.Count) -ForegroundColor Cyan

if ($errorCount -gt 0) {
    Write-Host "FAIL — terminology lint found errors." -ForegroundColor Red
    exit 1
}

Write-Host "PASS (with warnings)." -ForegroundColor Green
exit 0
