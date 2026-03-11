---
name: setup-update
description: >
  Re-scans the codebase and updates .agents configuration after significant changes. Use when the
  user says "update agents config", "refresh setup", "stack changed", "rescan", or when major
  dependencies, architecture patterns, or project structure have changed since the initial setup.
  Lighter than /setup-init — proposes updates rather than regenerating from scratch.
---

# Setup Update

Re-scan the codebase and propose updates to .agents configuration. This is a lighter version of
`/setup-init` that detects drift between the current codebase and the existing configuration.

## When to Use

- After adding a new major dependency or framework
- After restructuring the project (new packages, renamed directories)
- After changing build tools or package managers
- After changing architecture patterns
- Periodically (e.g., quarterly) to catch gradual drift

## Steps

### 1. Re-scan the Codebase

Run the same detection as `/setup-init` Phase 1:
- Detect languages, frameworks, tools from manifest files
- Analyze directory structure
- Check for new config files (linters, formatters, CI)

### 2. Compare Against Current Config

Read the existing configuration:
- `AGENTS.md` — current tech stack section, code standards, architecture
- `.agents/agents/review/*.md` — current agent persona checklists
- `.agents/agents/housekeeping/repo-housekeeper.md` — current structure checks
- `.agents/docs/shared/architecture/project-overview.md` — current architecture doc

### 3. Identify Drift

For each configuration area, classify changes:

| Type | Meaning | Example |
|------|---------|---------|
| **New** | Something in the codebase not reflected in config | New framework added, new directory structure |
| **Stale** | Config references something no longer present | Removed dependency still in patterns-reviewer |
| **Changed** | Something evolved | Build tool changed, naming convention shifted |
| **Consistent** | No drift detected | Config matches codebase |

### 4. Present Drift Report

```
## Configuration Drift Report

### New (add to config)
- Detected {framework} in dependencies — not reflected in patterns-reviewer or AGENTS.md
- New directory `{path}` — not in repo-housekeeper checks

### Stale (remove from config)
- AGENTS.md references {tool} but it's no longer in the project
- architecture-reviewer checks for {pattern} but code has moved to {new pattern}

### Changed (update config)
- Package manager changed from {old} to {new}
- Naming convention shifted from {old} to {new} in recent files

### Consistent (no changes needed)
- {N} areas checked, no drift

### Summary
{N} updates recommended across {N} files
```

### 5. Apply Updates (with approval)

For each proposed change:
1. Show the specific edit (old → new)
2. Wait for user approval
3. Apply the change using Edit tool

After all updates:
- Run `.agents/update.sh` (or `update.ps1`) to redistribute
- Update `.agents/docs/shared/architecture/project-overview.md` if structure changed
- Report what was updated

## Rules

- NEVER regenerate files from scratch — only propose targeted edits
- ALWAYS show proposed changes before applying
- ALWAYS preserve user customizations — only update auto-detected sections
- If significant changes are detected (new language, complete restructure), recommend running `/setup-init` instead
- Don't flag minor version bumps as drift — focus on structural and pattern changes
