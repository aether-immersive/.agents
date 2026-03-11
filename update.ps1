# .agents/update.ps1 — Sync AI agent configuration to tool-specific directories (Windows).
# Source of truth: .agents/ → copies skills, MCP, and hooks to .claude/, .gemini/, .cursor/, etc.
#
# Run this after:
#   - Initial setup (SETUP-PROMPT.md)
#   - Adding, editing, or removing skills
#   - Changing MCP server configuration
#   - Any time .agents/ content changes
#
# Usage:
#   .\.agents\update.ps1
#   Add to package.json scripts: "powershell -File .agents/update.ps1"
#
# No runtime dependencies required — pure PowerShell.

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
Set-Location $RepoRoot

Write-Host "Syncing .agents/ to tool-specific directories..."

# --- Skills ---
# Copy .agents/skills/ to each tool's expected directory
foreach ($targetDir in @(".claude\skills", ".gemini\skills")) {
    if (Test-Path $targetDir) {
        Remove-Item -Recurse -Force $targetDir
    }
    if ((Test-Path ".agents\skills") -and (Get-ChildItem ".agents\skills" -ErrorAction SilentlyContinue)) {
        New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
        Copy-Item -Recurse -Force ".agents\skills\*" $targetDir
    }
}

# --- MCP ---
# Copy .agents/mcp.json to tool-specific locations (skip Codex — uses TOML)
if (Test-Path ".agents\mcp.json") {
    Copy-Item -Force ".agents\mcp.json" ".mcp.json"
    New-Item -ItemType Directory -Force -Path ".cursor" | Out-Null
    Copy-Item -Force ".agents\mcp.json" ".cursor\mcp.json"
}

# --- Hooks Config ---
# Create .claude/settings.json with hooks if it doesn't exist.
# Note: Hook scripts are .sh files — requires bash (Git for Windows, WSL, or similar) to execute.
if (-not (Test-Path ".claude\settings.json")) {
    New-Item -ItemType Directory -Force -Path ".claude" | Out-Null
    @'
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": ".agents/hooks/check-skill-sync.sh"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".agents/hooks/no-youre-right.sh"
          }
        ]
      }
    ]
  }
}
'@ | Set-Content -Path ".claude\settings.json" -Encoding UTF8
    Write-Host "Created .claude/settings.json with hooks"
}

# --- Private Docs ---
# Create private docs directory structure (gitignored)
foreach ($dir in @("debugging", "architecture", "tooling", "convention", "mistake", "preference", "_archive")) {
    New-Item -ItemType Directory -Force -Path ".agents\docs\private\$dir" | Out-Null
}

# --- Orphan Check ---
# Detect skills in tool-specific dirs that don't exist in .agents/skills/ (the canonical source)
$orphansFound = $false
foreach ($toolDir in @(".claude\skills", ".gemini\skills")) {
    if (Test-Path $toolDir) {
        Get-ChildItem -Path $toolDir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $skillName = $_.Name
            if (-not (Test-Path ".agents\skills\$skillName")) {
                if (-not $orphansFound) {
                    Write-Host ""
                    Write-Host "WARNING: Orphan skills detected (exist in tool dirs but not in .agents/skills/):" -ForegroundColor Yellow
                    $orphansFound = $true
                }
                Write-Host "  - $toolDir\$skillName" -ForegroundColor Yellow
            }
        }
    }
}

if ($orphansFound) {
    Write-Host ""
    Write-Host "Run /skills-adopt-orphans to migrate them to .agents/skills/ (the canonical source)." -ForegroundColor Yellow
    Write-Host "Skills in tool-specific dirs will be overwritten on next update." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done. Skills and MCP config synced from .agents/"
