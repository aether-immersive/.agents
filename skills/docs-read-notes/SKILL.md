---
name: docs-read-notes
description: >
  Reads and browses notes from private, shared, or both. Use when the user asks "show me my notes",
  "what notes do we have", "read notes about X", "browse context", "list notes", "what did we learn
  about X", or when you need to check existing knowledge before starting work.
---

# Context Read Notes

Browse and read notes from the two-tier knowledge base.

## Locations

- **Private** (`.agents/docs/private/`) — Local notes, gitignored. Only on this machine.
- **Shared** (`.agents/docs/shared/`) — Team knowledge, tracked in git.

## Steps

### 1. Determine Scope

Ask or infer what the user wants:

- **Both** (default) — Read from private and shared
- **Private only** — User says "my notes", "local notes", "private notes"
- **Shared only** — User says "team notes", "shared notes"
- **Specific category** — User mentions a category (debugging, architecture, tooling, convention, mistake, preference)
- **Specific topic** — User asks about a particular subject

### 2. List Notes

For the determined scope, list all notes with:

```
## Notes

### Private (.agents/docs/private/)

#### debugging/
- `fix-auth-token-refresh-race-condition.md` — "Fix Auth Token Refresh Race Condition" (2026-03-01)

#### architecture/
- `service-layer-patterns.md` — "Service Layer Patterns" (2026-02-15)

### Shared (.agents/docs/shared/)

#### architecture/
- `project-overview.md` — "Project Architecture Overview" (2026-03-08)

### Summary
{N} private notes, {N} shared notes across {N} categories
```

### 3. Read Requested Notes

If the user asks about a specific topic or note:

- Read the full note content
- Highlight the key takeaways (Context, Detail, Resolution sections)
- Show related notes via `related` frontmatter and `[[wiki-links]]`

### 4. Suggest Actions

After presenting notes, suggest relevant follow-ups:

- `/docs-save-note` — if the user wants to capture something new
- `/docs-promote-notes` — if private notes look ready for sharing
- `/docs-search-notes` — if the user needs to find something specific

## Rules

- Default to showing both private and shared unless the user specifies
- Show frontmatter metadata (date, tags, source) in listings
- When reading a note, present the full content — don't summarize unless asked
- If no notes exist yet, say so and suggest using `/docs-save-note`
