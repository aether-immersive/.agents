#!/bin/bash
# Hook: warns when a file is written to .claude/skills/ that doesn't exist in .agents/skills/
# Used as a PostToolUse hook for Write/Edit operations.
#
# Reads the tool input from stdin (JSON with file_path field).
# Exits 0 (allow) always — this is advisory, not blocking.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path":"[^"]*"' | head -1 | cut -d'"' -f4)

# Only care about writes to .claude/skills/
case "$FILE_PATH" in
	*/.claude/skills/*)
		SKILL_NAME=$(echo "$FILE_PATH" | sed 's|.*/.claude/skills/||' | cut -d'/' -f1)
		if [ -n "$SKILL_NAME" ] && [ ! -d ".agents/skills/$SKILL_NAME" ]; then
			echo "Orphan skill '$SKILL_NAME' found in .claude/skills/ but not in .agents/skills/ (canonical source)." >&2
			echo "Run /skills-adopt-orphans to migrate it, or it will be overwritten on next update." >&2
		fi
		;;
esac

exit 0
