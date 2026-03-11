---
name: skills-adopt-orphans
description: >
  Finds skills created directly in tool-specific directories (.claude/skills/, .gemini/skills/,
  .agents/skills/ on other branches) that aren't in the canonical .agents/skills/ source of truth,
  and migrates them. Use when the user says "check for orphan skills", "adopt skills", or after
  creating a skill directly in any tool-specific directory.
---

# Adopt Orphan Skills

Find skills that exist in tool-specific directories but not in `.agents/skills/` (the canonical source) and migrate them.

## What counts as an orphan

A skill directory that exists in any of these locations but NOT in `.agents/skills/`:

- `.claude/skills/<name>/` — created directly by Claude Code
- `.gemini/skills/<name>/` — created directly by Gemini CLI
- Any `SKILL.md` or `*.skill.md` files found elsewhere in the repo

## Steps

1. List all skill directories in `.claude/skills/`, `.gemini/skills/`, and `.agents/skills/`
2. Search the repo for any `SKILL.md` or `*.skill.md` files outside `.agents/skills/` using Glob
3. For each orphan found:
   - Show the user the skill name, location, and description from its SKILL.md
   - Ask if they want to adopt it into `.agents/skills/`
4. For each skill to adopt:
   - Copy the skill directory to `.agents/skills/<name>/`
   - Ensure SKILL.md has proper YAML frontmatter (`name` and `description`)
   - If it's a loose `*.skill.md` file (not in a directory), wrap it in a proper `<name>/SKILL.md` structure
5. After adoption, run `.agents/update.sh` (or `update.ps1`) to redistribute to all tool directories
6. Report what was adopted

## Rules

- NEVER delete the original file — only copy TO `.agents/skills/`
- The update script overwrites tool-specific dirs on next run, so `.agents/skills/` must be the source of truth
- Skills must be flat (one level deep under `.agents/skills/`)
- Each skill directory must contain a `SKILL.md` file with YAML frontmatter
