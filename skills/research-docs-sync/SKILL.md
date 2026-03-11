---
name: research-docs-sync
description: >
  Syncs documentation with the current state of the repository. Use when the user asks "update
  the docs", "sync documentation", "are our docs current", "what's changed since docs were last
  updated", "docs are stale", or when significant code changes have landed and documentation
  needs to catch up. Reads docs from the filesystem (private, shared, README files), compares
  against git history since last sync, and proposes targeted updates.
---

# Research Docs Sync

Update documentation to match the current state of the repository. Uses git history to find
exactly what changed, asks the user for direction context, and proposes targeted doc updates.

Documentation is managed as markdown files accessed directly via the filesystem:
- `.agents/docs/private/` — Local working notes (gitignored)
- `.agents/docs/shared/` — Shared curated knowledge (tracked in git)
- `.agents/README.md` — System inventory
- `AGENTS.md` — Development guide

## Prerequisites

- The repo must be a git repository with commit history

## Steps

### 1. Gather Context

Do these in parallel:

**Read documentation files:**
- Read docs from `.agents/docs/private/`, `.agents/docs/shared/`, `.agents/README.md`, and `AGENTS.md`
- Look for `last-synced-commit` in each doc's YAML frontmatter
- Categorize: synced (has commit hash) vs never-synced (no hash)

**Get current git state:**
- Run `git rev-parse HEAD` to get current commit
- Run `git log --oneline -20` to see recent activity

**Ask the user:**
- "What's the current direction for the project? Any context about what you're building or where things are heading that should be reflected in the docs?"
- This human input is critical — git diffs show what changed, but only the user knows the intent

### 2. Detect Drift

Spawn the drift detector agent:

**Agent: Docs Drift Detector**
- Load persona from `.agents/agents/research/docs-drift-detector.md`
- For each doc with `last-synced-commit`: compute `git diff {synced-commit}..HEAD` and map changes to doc sections
- For docs without `last-synced-commit`: compare content against current codebase state
- Also check `.agents/README.md` — if any skills, agents, hooks, or MCP servers changed, flag the inventory

### 3. Present Drift Report

Show the user what's drifted before making any changes:

```
## Documentation Drift Report

### {Doc title} — {N} commits behind
- [Stale] "{section}" — {what changed}
- [Missing] No docs for {new feature}
- [Removed] "{section}" references deleted {thing}

### {Doc title} — never synced
- Needs full review

### .agents/README.md
- {inventory changes needed}

### Summary
{N} docs checked, {N} stale, {N} current
```

### 4. Write Updates

After user reviews the drift report and approves, spawn the docs writer:

**Agent: Docs Writer**
- Load persona from `.agents/agents/research/docs-writer.md`
- Input: drift report + user direction context + current HEAD commit
- For each approved update: present old → new diff, write directly to the filesystem on approval
- Update `last-synced-commit` frontmatter to current HEAD
- Update `.agents/README.md` inventory if needed

### 5. Finalize

After all updates are written:

**Save sync log to private:**
Invoke `/docs-save-note`:
- **Category**: `tooling`
- **Tags**: `docs-sync`
- **Title**: `docs-sync-{date}.md`
- **Content**: Which docs were updated, commit range covered, major changes made

**Confirm to user:**
```
## Docs Sync Complete

### Updated
- {Doc title} — synced to {short commit hash}
- {Doc title} — synced to {short commit hash}

### Skipped (user declined)
- {Doc title} — {reason}

### Next Sync
Run `/research-docs-sync` after your next batch of changes lands.
Current HEAD: {full commit hash}
```

## Frontmatter Convention

Every synced doc should have this in its YAML frontmatter:

```yaml
---
last-synced-commit: abc1234def5678
last-synced-date: 2026-03-09
synced-by: ai-agent
tags:
  - project-docs
---
```

- `last-synced-commit`: Full commit hash (not short) of HEAD when doc was last verified accurate
- `last-synced-date`: Date of last sync
- `synced-by`: The AI tool that performed the sync (e.g., `claude-code`, `gemini-cli`, `codex`)
- Preserve any existing tags — only add `project-docs` if not present

## Rules

- NEVER write without showing the user proposed changes first
- ALWAYS ask the user for direction context — git diffs show what changed, humans explain why
- ALWAYS update `last-synced-commit` after writing — this is how the next sync knows where to start
- Don't reorganize docs — just update content within existing structure unless the user asks for a restructure
- Verify code examples against the actual codebase before writing them into docs
