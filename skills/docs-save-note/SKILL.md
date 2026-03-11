---
name: docs-save-note
description: >
  Saves a structured note to .agents/docs/private/. Use when you learn something important,
  discover a pattern, debug a tricky issue, make a mistake worth remembering, or when the user asks
  you to "remember this", "note this", "save this", or "write this down". Also use after resolving
  errors to capture the root cause and fix for future reference.
---

# Context Save Note

Save a structured note to the private directory. Notes capture knowledge for future AI sessions and humans.

## When to Write Notes

- **Debugging wins** — Root cause + fix for non-obvious bugs
- **Architecture decisions** — Why something was done a certain way
- **Mistakes and corrections** — What went wrong, why, and the fix
- **Patterns discovered** — Recurring code patterns in this codebase
- **Environment gotchas** — Build issues, config quirks, tooling surprises
- **User preferences** — Workflow or style preferences the user expressed

## Note Structure

Every note MUST have YAML frontmatter and follow this template:

```markdown
---
tags:
  - ai-generated
  - {category}
date: {YYYY-MM-DD}
source: claude-code
related: []
---

# {Title}

## Context
{One sentence: what were you doing when this came up?}

## Detail
{The actual knowledge. Be specific — include file paths, error messages, code snippets.}

## Resolution
{What fixed it, or what the correct approach is. Skip if this is just an observation.}

## Related Files
- `path/to/relevant/file.ts`
```

## Categories (use as tags)

- `debugging` — Bug fixes and root cause analysis
- `architecture` — Design decisions and patterns
- `tooling` — Build system, dev environment, CLI tools
- `convention` — Coding standards and style rules
- `mistake` — Errors made and lessons learned
- `preference` — User workflow preferences

## Where to Write

### Default: Private (`.agents/docs/private/`)

Write to `.agents/docs/private/{category}/{title}.md`. This is the local private directory, gitignored.
Create the category directory if it doesn't exist.

```
.agents/docs/private/
├── debugging/
├── architecture/
├── tooling/
├── convention/
├── mistake/
├── preference/
└── _archive/
```

Notes written here are **private to this machine**. To share them with the team, use
`/docs-promote-notes` to promote valuable notes to `.agents/docs/shared/` (tracked in git).

## Rules

- Use kebab-case for filenames: `fix-auth-token-refresh-race-condition.md`
- Keep notes concise — future you will skim, not read
- Include file paths and line numbers when relevant
- Link to related notes using `[[wiki-links]]` in the `related` frontmatter
- Don't duplicate information already in AGENTS.md or CLAUDE.md
- Don't write notes about trivial or obvious things
