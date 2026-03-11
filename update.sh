#!/bin/bash
# .agents/update.sh — Sync AI agent configuration to tool-specific directories.
# Source of truth: .agents/ → copies skills, MCP, and hooks to .claude/, .gemini/, .cursor/, etc.
#
# Run this after:
#   - Initial setup (SETUP-PROMPT.md)
#   - Adding, editing, or removing skills
#   - Changing MCP server configuration
#   - Any time .agents/ content changes
#
# Usage:
#   .agents/update.sh
#   Add to package.json scripts: ".agents/update.sh"
#
# No runtime dependencies required — pure bash.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo "Syncing .agents/ to tool-specific directories..."

# --- Skills ---
# Copy .agents/skills/ to each tool's expected directory
for target_dir in .claude/skills .gemini/skills; do
    rm -rf "$target_dir"
    if [ -d ".agents/skills" ] && [ "$(ls -A .agents/skills 2>/dev/null)" ]; then
        mkdir -p "$target_dir"
        cp -r .agents/skills/* "$target_dir/"
    fi
done

# --- MCP ---
# Copy .agents/mcp.json to tool-specific locations (skip Codex — uses TOML)
if [ -f ".agents/mcp.json" ]; then
    cp .agents/mcp.json .mcp.json
    mkdir -p .cursor
    cp .agents/mcp.json .cursor/mcp.json
fi

# --- Hooks Config ---
# Create .claude/settings.json with hooks if it doesn't exist
if [ ! -f ".claude/settings.json" ]; then
    mkdir -p .claude
    cat > .claude/settings.json << 'HOOKS'
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
HOOKS
    echo "Created .claude/settings.json with hooks"
fi

# --- Private Docs ---
# Create private docs directory structure (gitignored)
for dir in debugging architecture tooling convention mistake preference _archive; do
    mkdir -p ".agents/docs/private/$dir"
done

# --- Orphan Check ---
# Detect skills in tool-specific dirs that don't exist in .agents/skills/ (the canonical source)
ORPHANS_FOUND=false
for tool_dir in .claude/skills .gemini/skills; do
    if [ -d "$tool_dir" ]; then
        for skill_path in "$tool_dir"/*/; do
            [ -d "$skill_path" ] || continue
            skill_name=$(basename "$skill_path")
            if [ ! -d ".agents/skills/$skill_name" ]; then
                if [ "$ORPHANS_FOUND" = false ]; then
                    echo ""
                    echo "⚠ Orphan skills detected (exist in tool dirs but not in .agents/skills/):"
                    ORPHANS_FOUND=true
                fi
                echo "  - $tool_dir/$skill_name"
            fi
        done
    fi
done

if [ "$ORPHANS_FOUND" = true ]; then
    echo ""
    echo "Run /skills-adopt-orphans to migrate them to .agents/skills/ (the canonical source)."
    echo "Skills in tool-specific dirs will be overwritten on next update."
fi

echo ""
echo "Done. Skills and MCP config synced from .agents/"
