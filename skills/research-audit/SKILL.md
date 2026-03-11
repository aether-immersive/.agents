---
name: research-audit
description: >
  Audits current dependencies and code patterns to find what's outdated, abandoned, or superseded.
  Use when the user asks "audit our deps", "are we using outdated libraries", "is there a better
  way to do X", "review our stack", "what should we update", "check for tech debt", "are our
  patterns current", or any question about whether current tools and approaches are still the
  best choice. Goes beyond version bumps — questions whether each dep is still the right pick.
---

# Research Audit

Deep audit of the monorepo's dependencies and code patterns. Questions whether current choices
are still the best ones and surfaces modernization opportunities.

## Steps

### 1. Determine Scope

Ask the user (or infer from context):
- **Full audit**: Review all deps and major patterns (takes longer)
- **Targeted audit**: Focus on a specific area (e.g., "audit our data layer", "check our auth deps")
- **Pattern audit**: Focus on how something is done, not which library (e.g., "are our state management patterns current?")

### 2. Spawn Research Agents in Parallel

Launch 4 agents using the Agent tool, all in parallel:

**Agent 1: Deps Auditor**
- Load persona from `.agents/agents/research/deps-auditor.md`
- Task: Read dependency files (`package.json` catalogs, `go.mod`), research health/status of each dep in scope
- Must use WebSearch for maintenance status, successor info, deprecation notices

**Agent 2: Modernization Analyst**
- Load persona from `.agents/agents/research/modernization-analyst.md`
- Task: Examine current code patterns in the scoped area, research whether better approaches exist
- Focus on: framework-specific patterns, language version features, runtime-native APIs, current best practices

**Agent 3: Community Analyst**
- Load persona from `.agents/agents/research/community-analyst.md`
- Task: Search Reddit/HN for sentiment on the specific deps and patterns under review
- Focus on: migration stories, "what I wish I'd known", community-recommended alternatives

**Agent 4: Stack Checker**
- Load persona from `.agents/agents/research/stack-checker.md`
- Task: For each dep/pattern being audited, assess how deeply it's integrated and what migration effort looks like
- Map: file counts, adapter/facade usage, direct vs wrapped usage

### 3. Synthesize

After all 4 agents complete, act as the report-synthesizer (load persona from
`.agents/agents/research/report-synthesizer.md`):

- Cross-reference deps-auditor findings with community sentiment
- Weight modernization recommendations against stack-checker's migration effort
- Deduplicate (e.g., if deps-auditor and community-analyst both flag the same library)
- Classify every finding into exactly one bucket

### 4. Present Report

```
## Audit Report: {Scope}

### TL;DR
{2-3 sentence summary — the most important finding and recommended action}

### Critical (act now)
- **{dep/pattern}** — {what's wrong, what to do}
  - Evidence: {from deps-auditor + community}
  - Migration effort: {from stack-checker}
  - Replacement: {specific alternative with install command}

### Replace (plan migration)
- **{dep/pattern}** — {why, what with}
  - Evidence: {links, data}
  - Effort: {assessment}

### Modernize (update usage, keep dep)
- **{dep/pattern}** — {what's outdated about current usage}
  - Current: {how it's used now}
  - Modern: {how it should be used, with code example}

### Watch (revisit in 6 months)
- **{dep/pattern}** — {what's emerging, why not yet}

### Healthy (no action needed)
{List of deps/patterns that are still the right choice — briefly, to confirm they were reviewed}

### Community Highlights
- {Most impactful community signal}
- {Key migration story or gotcha}
```

### 5. Save to Vault

Invoke `/docs-save-note` to save the audit:
- **Category**: `architecture`
- **Tags**: `research-audit`, plus specific dep/pattern tags
- **Title**: `audit-{scope-summary}.md` (kebab-case)
- If any findings are Critical or Replace, add `promote: true` to frontmatter — these should be promoted to shared via `/docs-promote-notes`

## Rules

- ALWAYS use WebSearch for every dep being audited — don't rely on training data for maintenance status
- NEVER recommend replacing a dep with something less popular — adoption must be equal or higher
- ALWAYS include migration effort from stack-checker — a perfect library you can't adopt is a useless recommendation
- For "Healthy" items, still list them — confirms they were reviewed, not skipped
- Don't flag a library as stale just because it hasn't released recently — some libraries are done. Check for ignored issues/PRs instead.
- Focus on the user's scope — if they said "audit our data layer", don't audit their CSS framework
- Use a documentation MCP server (e.g., Context7) for doc lookups when checking modern patterns
