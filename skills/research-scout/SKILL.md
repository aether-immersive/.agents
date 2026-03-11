---
name: research-scout
description: >
  Finds the best library, tool, or approach for a specific goal. Use when the user asks "what's
  the best library for X", "find me a tool for Y", "what should I use for Z", "is there something
  better than X", "what are people using for Y", or any question about choosing a technology,
  library, or approach. Searches the web, mines community sentiment, and checks against the
  existing stack.
---

# Research Scout

Find the best library, tool, or approach for a given goal. Searches live web data, gathers
community sentiment, and grounds recommendations against the monorepo's existing stack.

## Steps

### 1. Clarify the Goal

Before spawning agents, make sure you understand:
- What capability is needed (be specific)
- What language/runtime (check AGENTS.md for the project's tech stack)
- Any constraints (license requirements, build system compatibility, framework alignment)

If the user's request is vague, ask one clarifying question before proceeding.

### 2. Spawn Research Agents in Parallel

Launch 3 agents using the Agent tool, all in parallel:

**Agent 1: Library Scout**
- Load persona from `.agents/agents/research/library-scout.md`
- Task: Search the web for libraries/tools that accomplish the user's goal
- Must use WebSearch for live data — do not rely on training knowledge alone

**Agent 2: Community Analyst**
- Load persona from `.agents/agents/research/community-analyst.md`
- Task: Search Reddit, HN, dev forums for real-world experience with the candidates
- Focus on: what people actually use, migration stories, pain points, gotchas

**Agent 3: Stack Checker**
- Load persona from `.agents/agents/research/stack-checker.md`
- Task: Scan the monorepo to see what's already installed, how it's used, and how proposed changes would fit
- Read dependency manifests and check for existing shared utilities or abstractions

### 3. Synthesize

After all 3 agents complete, act as the report-synthesizer (load persona from
`.agents/agents/research/report-synthesizer.md`):

- Deduplicate findings across agents
- Resolve any conflicts (e.g., high stars but community complaints)
- Rank recommendations by: adoption × ecosystem fit × migration effort
- Produce the final report

### 4. Present Report

Show the user a single consolidated report:

```
## Research Report: {Goal}

### TL;DR
{2-3 sentence recommendation}

### Top Pick: {library}
- Stars: {N} | Downloads: {N}/week | Last commit: {date}
- Why: {synthesis of library-scout + community evidence}
- Fits your stack: {from stack-checker — conflicts, existing alternatives, migration effort}
- Install: `{command}`

### Runner-up: {library}
- {same format, brief}

### Community Pulse
- {Key sentiment — what real developers say}
- {Top gotcha or praise pattern}

### What You Already Have
- {Existing deps/patterns that are relevant — from stack-checker}

### Also Considered
| Library | Stars | Status | Why Not |
|---------|-------|--------|---------|
| ...     | ...   | ...    | ...     |
```

### 5. Save to Private

Invoke `/docs-save-note` to save the findings:
- **Category**: `architecture` (for library/pattern choices) or `tooling` (for dev tools)
- **Tags**: `research-scout`, plus technology-specific tags
- **Title**: `research-{goal-summary}.md` (kebab-case)
- If the finding is significant (changes a key architectural decision), add `promote: true` to frontmatter

## Rules

- ALWAYS use WebSearch — never recommend based solely on training data
- ALWAYS check the existing stack before recommending — don't suggest what they already have
- NEVER recommend a library with lower adoption than an available alternative (unless concrete technical justification)
- The minimum GitHub stars threshold is 1,000 for JS/TS and 500 for Go — below that needs exceptional justification
- If the standard library covers the use case, say so — don't recommend a dep for built-in functionality
- Use a documentation MCP server (e.g., Context7) for library doc lookups when available
- Keep the report actionable — include install commands, code examples, and migration steps
