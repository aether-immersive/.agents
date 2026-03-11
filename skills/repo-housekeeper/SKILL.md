---
name: repo-housekeeper
description: >
  Audits the repository for misplaced files, naming violations, stale artifacts, orphaned configs,
  and structural inconsistencies. Use when the user says "clean up the repo", "check for mess",
  "housekeeping", "audit structure", or when something feels out of place. Also use proactively
  after major refactors or branch merges.
---

# Repo Housekeeper

Audit the monorepo for structural hygiene. Find files that are out of place, naming conventions
that are violated, stale artifacts that should be cleaned up, and inconsistencies across the
directory structure.

## Steps

### 1. Audit All Areas

Run these checks in parallel using the Agent tool, one agent per area. Each agent gets the
housekeeper persona loaded from `.agents/agents/housekeeping/repo-housekeeper.md` and is scoped
to its specific area.

**Area 1: `.agents/` System Integrity**
- Skills in `.agents/skills/` follow `{category}-{action}` naming (lowercase, single hyphens, no consecutive hyphens)
- Every skill directory has a `SKILL.md` with valid YAML frontmatter (`name` and `description`)
- `name` field in SKILL.md matches directory name exactly
- Agent personas in `.agents/agents/` are organized by category subdirectory (`review/`, `housekeeping/`, etc.)
- Agent persona filenames are kebab-case `.md` files
- No orphan skills in `.claude/skills/` or `.gemini/skills/` that don't exist in `.agents/skills/`
- `.agents/mcp.json` matches `.mcp.json` and `.cursor/mcp.json` (update.sh was run)
- No stale files (e.g., completed PLAN.md files, duplicate skill definitions outside `.agents/`)

**Area 2: Project Structure**
- Source files in correct directories per project conventions (see AGENTS.md)
- Modules/packages follow consistent internal structure
- No loose files at wrong directory levels
- Build config files exist where expected

**Area 3: Shared Code Consistency**
- Shared utilities, libraries, or packages follow consistent structure
- No circular dependencies between packages/modules
- Package manifests present where expected
- No orphaned package configs outside workspace definitions (if monorepo)

**Area 4: Config & Metadata Files**
- `package.json` workspace globs match actual directory structure
- No orphaned `package.json` files outside workspace globs
- `go.mod` module path is correct
- `.gitignore` covers expected patterns (`.agents/docs/`, `node_modules/`, etc.)
- No committed secrets (`.env` files, credentials, API keys)
- No duplicate config files (e.g., `traction/rocks.skill.md` duplicating a canonical skill)
- No stale planning documents (completed TODOs, implemented plans)

**Area 5: Naming Convention Enforcement**
- Source files follow project naming convention (see AGENTS.md)
- Skill directories: `{category}-{action}` with single hyphens
- Agent persona files: kebab-case `.md`
- Directory naming matches project convention
- Config/build file naming matches existing patterns

### 2. Present Findings

Show the user a prioritized report:

```
# Housekeeping Report

## Critical (fix immediately)
- [path] Description of structural violation or misplaced file

## Warnings (should fix)
- [path] Description of naming violation or inconsistency

## Info (nice to fix)
- [path] Description of minor cleanup opportunity

## Stale Artifacts
- [path] Description — can be deleted because [reason]

## Summary
X critical, Y warnings, Z info items found
```

### 3. Fix (with user approval)

For each category, ask before acting:

- **Move files** to correct locations
- **Rename files** to match conventions
- **Delete stale artifacts** (completed plans, duplicates)
- **Create missing files** (BUILD.bazel, package.json)
- **Run `.agents/update.sh`** (or `update.ps1`) to sync skill distributions
- **Update README/inventory** if structure changed

## Rules

- NEVER delete files without explicit user approval
- NEVER modify package manager configs, build system files, or dependency manifests without approval
- Show the user what you plan to do before doing anything
- For each finding, explain WHY it's wrong and what the correct pattern is
- Reference the nearest correct neighbor as the example to follow
- Run `git status` first to avoid flagging uncommitted work-in-progress as violations
