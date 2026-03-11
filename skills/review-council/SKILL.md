---
name: review-council
description: >
  Runs a council of 8 specialized reviewers in parallel on recent code changes. Use when the user
  asks for a code review, says "review this", "check my code", or before committing significant
  changes. Also trigger when the user mentions security audit, architecture review, or pattern check.
---

# Review Council

Spawn eight specialized reviewer agents in parallel to analyze code changes. Each reviewer has a
distinct checklist tuned to this codebase.

## Steps

1. **Identify the changes to review.** Use `git diff` (staged + unstaged) or `git diff main...HEAD` for branch reviews. If the user specifies files, scope to those.

2. **Read the changed files** so you have the full context, not just the diff.

3. **Spawn eight subagents in parallel** using the Agent tool. Each agent gets:
   - Its persona loaded via the file path (read the file and include its content in the prompt)
   - The diff and full file contents
   - Instructions to follow its checklist and output format

   The eight agents:
   - `.agents/agents/review/security-auditor.md` — vulnerabilities, secrets, injection, auth
   - `.agents/agents/review/architecture-reviewer.md` — dependency direction, architectural boundaries, patterns
   - `.agents/agents/review/performance-reviewer.md` — N+1 queries, memory leaks, performance bottlenecks
   - `.agents/agents/review/patterns-reviewer.md` — framework conventions, language idioms, formatting rules
   - `.agents/agents/review/code-simplifier.md` — over-engineering, redundancy, readability
   - `.agents/agents/review/wheel-detector.md` — reinvented wheels, ignored built-ins, codebase duplicates
   - `.agents/agents/review/consistency-checker.md` — matches existing patterns, file structure, naming
   - `.agents/agents/review/test-reviewer.md` — test coverage, edge cases, test quality, stale tests

4. **Collect results** from all eight agents.

5. **Present a unified report** to the user:

```
# Review Council Report

## Security
[security-auditor findings]

## Architecture
[architecture-reviewer findings]

## Performance
[performance-reviewer findings]

## Patterns
[patterns-reviewer findings]

## Simplicity
[code-simplifier findings]

## Wheels
[wheel-detector findings]

## Consistency
[consistency-checker findings]

## Tests
[test-reviewer findings]

## Summary
[X critical, Y warnings, Z info across all reviewers]
```

6. **If any reviewer found Critical issues**, highlight them at the top of the summary.

## Single Reviewer Mode

If the user asks for a specific review (e.g., "security review", "check architecture", "simplify this"),
spawn only the relevant agent instead of the full council. Match keywords:

- "security" / "vulnerabilities" / "audit" → security-auditor
- "architecture" / "dependency" / "boundaries" → architecture-reviewer
- "performance" / "speed" / "memory" / "N+1" → performance-reviewer
- "patterns" / "conventions" / "formatting" / "style" → patterns-reviewer
- "simplify" / "complexity" / "over-engineered" → code-simplifier
- "wheel" / "reinvent" / "built-in" / "library" → wheel-detector
- "consistency" / "matches" / "existing patterns" → consistency-checker
- "test" / "tests" / "coverage" / "untested" / "edge cases" → test-reviewer

## Notes

- Run reviewers in PARALLEL (single message with eight Agent tool calls) for speed
- Each reviewer runs in its own context window — they don't influence each other
- If the diff is very large, split by domain and run multiple rounds
- Don't fabricate findings — if a reviewer says "clean", report it as clean
