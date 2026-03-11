---
name: docs-search-notes
description: >
  Searches across private and shared notes by keyword, tag, or category. Use when the user asks
  "search notes for X", "find notes about X", "do we have anything on X", "have we seen this
  before", or when you need to check if knowledge already exists before saving a new note.
---

# Context Search Notes

Search across private and shared notes by keyword, tag, or category.

## Locations

- **Private** (`.agents/docs/private/`) — Local notes, gitignored.
- **Shared** (`.agents/docs/shared/`) — Team knowledge, tracked in git.

## Steps

### 1. Determine Search Criteria

Parse the user's request for:

- **Keywords** — Free text to search in note titles and content
- **Tags** — Specific tags from frontmatter (e.g., `debugging`, `architecture`, `ai-generated`)
- **Category** — Folder name (debugging, architecture, tooling, convention, mistake, preference)
- **Date range** — Notes from a specific period
- **Source** — Who wrote it (`claude-code`, `human`, etc.)

### 2. Search Both Tiers

Search across both `.agents/docs/private/` and `.agents/docs/shared/`:

1. **Filename match** — Search filenames for keywords (kebab-case)
2. **Frontmatter match** — Search tags, related fields, date
3. **Content match** — Search note body for keywords using Grep

### 3. Present Results

Show results ranked by relevance:

```
## Search Results for "{query}"

### Matches

1. **[private] debugging/fix-auth-token-refresh-race-condition.md**
   - Title: "Fix Auth Token Refresh Race Condition"
   - Tags: debugging, auth, async
   - Date: 2026-03-01
   - Match: "...the token refresh was racing with the API call because..."

2. **[shared] architecture/project-overview.md**
   - Title: "Project Architecture Overview"
   - Tags: architecture, project-docs
   - Date: 2026-03-08
   - Match: "...the service layer delegates to repository interfaces..."

### Summary
{N} results found ({N} private, {N} shared)
```

### 4. Offer Follow-ups

- Read a specific result in full
- Save a new note if the search came up empty (`/docs-save-note`)
- Refine the search with different keywords

## Rules

- Always search both private and shared unless the user specifies one
- Show which tier each result comes from ([private] or [shared])
- Include a content snippet showing where the keyword matched
- If no results found, say so clearly and suggest saving a note if relevant
- Don't read every note fully — use Grep for efficient content search, only read matches
