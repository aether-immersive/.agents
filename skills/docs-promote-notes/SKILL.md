---
name: docs-promote-notes
description: >
  Audits private notes and promotes valuable ones to shared. Use when the user says "promote notes",
  "clean up notes", "organize notes", "fix note structure", "move notes to shared", or when
  AI-generated notes need consolidation. Also use to find and fix orphan notes, merge duplicates,
  standardize frontmatter, and enforce folder structure conventions.
---

# Context Promote Notes

Audit private notes, organize them, and promote valuable ones to the shared knowledge base.

## Two-Tier System

- **Private** (`.agents/docs/private/`) — Gitignored working space. `/docs-save-note` writes here.
- **Shared** (`.agents/docs/shared/`) — Tracked in git. Curated knowledge for the team.

Notes start in private. During promotion, valuable notes get **copied** to shared.

## Steps

### 1. Audit Private Notes

Scan `.agents/docs/private/` and report:

- **Orphan notes** — Files with no backlinks and no tags
- **Missing frontmatter** — Notes without YAML frontmatter or missing required fields
- **Duplicate topics** — Multiple notes covering the same thing
- **Stale notes** — Notes about resolved issues or outdated patterns
- **Miscategorized** — Notes in wrong folders based on their content/tags
- **Broken links** — `[[wiki-links]]` pointing to non-existent notes
- **Promotion candidates** — Notes valuable enough to share (stable patterns, architecture decisions, confirmed debugging fixes)

### 2. Audit Shared Notes

Also scan `.agents/docs/shared/` for the same issues. Additionally check:

- **Outdated shared notes** — Information that's no longer accurate
- **Duplicates across tiers** — Same knowledge in both private and shared

### 3. Present Findings

Show the user a summary:

```
## Notes Audit

### Private (.agents/docs/private/)
- X notes total
- X orphan notes (no links, no tags)
- X notes missing frontmatter
- X potential duplicates
- X notes in wrong category folder

### Shared (.agents/docs/shared/)
- X notes total
- X outdated notes
- X duplicates with private

### Promotion Candidates
- private/{category}/note-a.md — "Title" — [why it's worth sharing]
- private/{category}/note-b.md — "Title" — [why it's worth sharing]

### Recommendations
- Promote: [list of private notes to copy to shared]
- Merge: [list of duplicate pairs]
- Move: [list of miscategorized notes]
- Archive: [list of stale notes]
```

### 4. Fix (with user approval)

For each fix category, ask before acting:

- **Promote** — Copy valuable private notes to `.agents/docs/shared/{category}/`. Keep the private copy.
- **Merge duplicates** — Combine content, keep the better-organized note
- **Add frontmatter** — Add standard YAML frontmatter to notes missing it
- **Recategorize** — Move notes to correct `{category}/` folder
- **Archive stale** — Move to `_archive/` (don't delete)
- **Fix links** — Update broken wiki-links or remove dead ones

### 5. Standardize Structure

Ensure both locations follow this structure:

```
{root}/
├── debugging/       # Bug fixes and root cause analysis
├── architecture/    # Design decisions and patterns
├── tooling/         # Build system, dev environment
├── convention/      # Coding standards and style
├── mistake/         # Errors and lessons learned
├── preference/      # User workflow preferences
└── _archive/        # Stale notes (don't delete, move here)
```

## Promotion Criteria

A note is worth promoting to shared when:

- It documents a **stable pattern** confirmed across multiple interactions
- It captures an **architecture decision** that affects the whole team
- It records a **debugging fix** for a non-obvious issue others will hit
- It documents a **convention** the team should follow
- It's been **validated** — the information is correct, not speculative

A note should stay in private when:

- It's session-specific or work-in-progress
- It's speculative or unverified
- It duplicates AGENTS.md or CLAUDE.md content
- It's only relevant to one person's workflow

## Rules

- NEVER delete notes without explicit user approval
- Always archive instead of delete (move to `_archive/`)
- Preserve all original content when merging — add, don't subtract
- Show the user what you plan to do before doing it
- When promoting, COPY to shared — don't move from private
