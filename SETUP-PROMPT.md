# .agents Setup Prompt

**Read this entire file, then follow the instructions below.**

You are setting up the `.agents/` AI agent configuration system for this project. Your job is to
deeply analyze this codebase, interview the developer about their architecture and preferences,
and generate all project-specific configuration files.

After setup, run `.agents/update.sh` (or `.agents/update.ps1` on Windows) to distribute
skills and MCP config to tool-specific directories.

---

## Phase 0: Pre-flight Check

Before scanning, verify the setup environment:

1. **Check for template `.git/`** — If `.agents/.git/` exists, it's the template repo's git history, not the project's. Inform the developer:
   "I see `.agents/.git/` exists — this is from the template repo. You should delete it so `.agents/` becomes part of your project's git history instead of being a nested repo. Want me to remove it?"
   Only delete with explicit approval.

2. **Verify `.agents/` is in the project root** — The `.agents/` directory should be a sibling of the project's source code, not nested inside a subdirectory.

3. **Check for existing `.gitignore`** — Note whether the project has a `.gitignore` already. The generated entries (Phase 3.10) need to be appended to it, or a new one created. Reference `.agents/gitignore-template` for the exact entries needed.

---

## Phase 1: Deep Scan (automated — no questions yet)

Run all of these in parallel or sequentially. Gather as much information as possible before
asking the developer any questions.

### 1.1 Detect Repo Type
- Check for monorepo signals: workspace definitions in `package.json` (workspaces field), `pnpm-workspace.yaml`, `lerna.json`, `nx.json`, `turbo.json`, `MODULE.bazel`, `WORKSPACE`
- Check for multi-repo signals: `.gitmodules`, multiple `.git` directories
- Default: single repo

### 1.2 Detect Tech Stack
Read manifest and config files to determine languages, frameworks, and tools:

**Package managers & manifests:**
- `package.json` → Node/Bun/Deno ecosystem, detect which via lockfile (`bun.lock` = Bun, `pnpm-lock.yaml` = pnpm, `yarn.lock` = Yarn, `package-lock.json` = npm, `deno.lock` = Deno)
- `go.mod` → Go (note version)
- `Cargo.toml` → Rust
- `pyproject.toml` / `requirements.txt` / `setup.py` / `Pipfile` → Python
- `Gemfile` → Ruby
- `pom.xml` / `build.gradle` / `build.gradle.kts` → Java/Kotlin
- `mix.exs` → Elixir
- `*.csproj` / `*.sln` → .NET/C#
- `composer.json` → PHP
- `pubspec.yaml` → Dart/Flutter

**Frameworks (from dependencies):**
- React, Next.js, Vue, Nuxt, Svelte, SvelteKit, Angular, Solid, Astro, Remix
- Express, Fastify, Hono, Koa, NestJS, Django, Flask, FastAPI, Rails, Spring Boot, Phoenix, Gin, Echo, Fiber
- Three.js, Threlte, React Three Fiber, Babylon.js
- Tailwind, styled-components, CSS modules

**Build tools:**
- Bazel, Nx, Turbo, Lerna, Vite, Webpack, Rollup, esbuild, tsup, Parcel
- Make, CMake, Gradle, Maven

**Testing:**
- Jest, Vitest, Bun test, Mocha, Playwright, Cypress, Testing Library
- Go testing, testify, gomock
- pytest, unittest
- RSpec, minitest

**Linting/Formatting:**
- Biome, ESLint, Prettier, Rome, oxlint
- gofmt, golangci-lint, staticcheck
- Ruff, Black, flake8, mypy
- RuboCop, Clippy

**Databases:**
- PostgreSQL, MySQL, SQLite, MongoDB, Redis, DynamoDB
- ORMs: Prisma, Drizzle, Kysely, TypeORM, Sequelize, GORM, SQLAlchemy, ActiveRecord

**Infrastructure:**
- Docker, Docker Compose, Kubernetes
- Terraform, OpenTofu, Pulumi, CDK, CloudFormation, Ansible
- AWS, GCP, Azure, Vercel, Netlify, Fly.io, Railway

### 1.3 Read Existing AI Config
Check for and read any existing configuration:
- `CLAUDE.md` or `.claude/CLAUDE.md`
- `GEMINI.md`
- `AGENTS.md` (check if it's the template stub or has real content)
- `.cursorrules` or `.cursor/rules/*.mdc`
- `.github/copilot-instructions.md`
- Any `.claude/`, `.gemini/`, `.cursor/` directories

If any of these exist with real content (not just the template stub), **preserve their rules
and integrate them** into the generated config. Do NOT discard existing instructions.

### 1.4 Analyze Project Structure
- Run a directory tree (3-4 levels deep) to understand the layout
- Identify key directories: source, tests, config, docs, infrastructure, scripts
- For monorepos: identify package/service boundaries

### 1.5 Detect Patterns
- Sample 5-10 source files across the project to identify:
  - Naming conventions (camelCase, snake_case, kebab-case for files)
  - Import organization patterns
  - Error handling patterns
  - Architecture patterns (layered, hexagonal, clean, MVC, modular, flat)
  - State management patterns (if frontend)

### 1.6 Check Git History
- `git log --oneline -20` — recent activity, commit message style
- `git branch -a` — branching strategy (main/develop, trunk-based, feature branches)
- Check for `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, `bitbucket-pipelines.yml`, `.circleci/config.yml`

### 1.7 Discover Existing Knowledge

Scan for documentation, context files, and knowledge repositories that already exist in the project:

**Documentation directories:**
- `docs/`, `doc/`, `documentation/`
- `wiki/`, `.wiki/`
- `notes/`, `.notes/`
- `adr/`, `adrs/`, `docs/adr/`, `docs/decisions/`
- `guides/`, `runbooks/`

**AI tool context/memory:**
- `.claude/memory/`, `.claude/MEMORY.md`
- `.gemini/context/`, `.gemini/memory/`
- `.cursor/rules/` (existing rules files)
- `.github/copilot-instructions.md`

**Project knowledge files:**
- `ARCHITECTURE.md`, `DESIGN.md`, `CONVENTIONS.md`, `STYLE_GUIDE.md`
- `CONTRIBUTING.md`, `DEVELOPMENT.md`, `ONBOARDING.md`
- `README.md` (may contain architecture/setup knowledge beyond basic description)
- `CHANGELOG.md`, `HISTORY.md`
- `docs/api/`, `docs/architecture/`, `docs/guides/`

**Existing structured knowledge:**
- Any `.md` files with YAML frontmatter (already structured as notes)
- ADR files (Architecture Decision Records) — numbered markdown files
- Runbooks or playbooks
- Postmortem / incident reports

For each source found, note:
- What it is and where it lives
- Whether it contains actionable knowledge (architecture decisions, conventions, debugging tips, patterns)
- Whether it's current or potentially stale
- How much content there is (a few files vs a large knowledge base)

---

## Phase 2: Developer Interview

Based on what you found in Phase 1, ask targeted questions. **Skip questions where the scan
already provided clear answers.** Group questions logically — don't ask one at a time.

### Question Block 1: Architecture & Patterns
Present what you found and ask for confirmation/correction:

"Here's what I detected about your project:
- **Repo type**: {single/monorepo/multi-repo}
- **Languages**: {list}
- **Frameworks**: {list}
- **Architecture pattern**: {what you detected or 'unclear'}
- **Build system**: {list}
- **Package manager**: {name}

Is this accurate? Anything I missed or got wrong?

About your architecture:
- What pattern do you follow? (layered, hexagonal/ports-adapters, clean architecture, MVC, modular, domain-driven, or something else)
- Are there specific architectural boundaries or rules that MUST be enforced? (e.g., 'domain never imports infrastructure', 'no cross-service imports')
- Any dependency direction rules?"

### Question Block 2: Code Conventions
"I found these conventions in your code:
- **Formatting**: {what linter/formatter detected, settings if available}
- **Naming**: {file naming pattern detected}
- **Import style**: {pattern detected}

Any conventions NOT captured in config files that I should know about? For example:
- Preferred error handling patterns
- Logging conventions
- Comment/documentation style
- Git commit message format"

### Question Block 3: Development Workflow
"Your development workflow:
- **Testing**: What's your testing strategy? (unit-heavy, integration-focused, E2E, TDD, etc.) What should always be tested?
- **CI/CD**: {what was detected}. How does deployment work? What environments exist?
- **Code review**: Any specific review requirements or conventions?
- **Branch strategy**: {what was detected}. Anything specific about how branches/PRs work?"

### Question Block 4: Cardinal Rules
"Beyond the standard git safety rules (never commit without permission, never make irreversible changes), what should an AI agent NEVER do in this project?

Examples:
- Never modify database schemas without approval
- Never touch the auth/payment/billing system without explicit request
- Never deploy to production
- Never run certain commands
- Specific files/directories that should never be modified"

### Question Block 5: Integration & Tools
"What external tools do you use that AI agents should integrate with?
- **Error tracking**: Sentry, Datadog, Bugsnag, Raygun, etc.?
- **Project management**: Notion, Linear, Jira, GitHub Projects?
- **Communication**: Slack, Discord?
- **Documentation**: Notion, Confluence, GitBook?
- **Browser testing**: Playwright, Cypress?
- **Any other MCP servers you use or want?**"

### Question Block 6: Domain Knowledge
"What would a new developer need to understand about this codebase that isn't obvious from the code? Any tribal knowledge, historical decisions, or 'here be dragons' areas?"

### Question Block 7: Cursor (optional)
"Do you use Cursor? If so, should I generate Cursor rules? I can create:
- A single `.cursor/rules/agents.mdc` with all instructions (simplest)
- Multiple `.mdc` files split by concern (cardinal-rules.mdc, tech-stack.mdc, code-standards.mdc)"

### Question Block 8: Knowledge Migration (conditional)
Only ask this if Phase 1.7 discovered existing knowledge sources. Skip entirely if nothing was found.

"I found existing documentation and knowledge in your project:

{For each source found, list:}
- **{type}**: `{path}` — {brief description of content, e.g., '12 ADR files', '3 runbooks', 'architecture overview'}

Would you like me to migrate any of this into `.agents/docs/shared/`? I'll:
- Convert files to the standard note format (with YAML frontmatter: tags, date, source)
- Categorize them into the right directories (architecture/, debugging/, convention/, tooling/)
- Preserve the original content — just add structure

Options:
- **All** — migrate everything found
- **Select** — tell me which sources to include
- **Skip** — don't migrate anything, I can always do it later with `/docs-save-note`

If migrating, should I **keep** or **remove** the originals?
- **Keep** — copy into `.agents/docs/shared/`, leave originals in place
- **Remove** — move into `.agents/docs/shared/`, delete the originals to consolidate everything in one place"

---

## Phase 3: Generate Configuration

Based on scan results + developer answers, generate all files below.

### 3.1 Generate AGENTS.md (at project root)

This is the canonical instructions file. All other tool configs reference it.

Structure:
```markdown
# AGENTS.md — {Project Name} Development Guide

This document provides guidance for AI agents working with this project.

## CARDINAL RULE — NO IRREVERSIBLE CHANGES

**NEVER make irreversible changes without explicit permission:**

- **NEVER** commit or push changes to git — the human must review all code before committing
- **NEVER** install, add, or remove packages/dependencies without explicit user approval
- **NEVER** modify package manager config, lockfiles, or workspace definitions without explicit user approval
- **NEVER** run database migrations, drops, or destructive operations without explicit user approval
- **NEVER** deploy, apply infrastructure changes, or mutate remote state without explicit user approval
- **NEVER** delete important files, production data, or anything not tracked by git without explicit user approval
- **NEVER** make ANY change that cannot be completely undone by running `git checkout .`
{+ any project-specific cardinal rules from the developer interview}

### Safety Protocol
1. **Before ANY potentially destructive operation**, ASK first.
2. **Operations that REQUIRE explicit permission:**
   {generated list based on detected tools}
3. **Safe operations (no permission needed):**
   - Reading files
   - Editing source files tracked by git
   - Running read-only queries
   - Running tests
   - Searching and grepping
   - Building (compile/bundle)

## Repository Structure

{Generated directory tree based on scan, 2-3 levels deep}

## Tech Stack

{Generated table of languages, frameworks, tools — confirmed by developer}

## Code Standards

{Generated from linter/formatter config + developer answers}
{Include framework-specific conventions}

## Architecture

{Generated from detected pattern + developer answers}
{Include dependency direction and boundary rules}

## Development Commands

{Generated from package.json scripts, Makefile targets, or detected CI commands}

## Learning & Knowledge Capture

When you make a mistake, get corrected, discover something unexpected, or resolve a non-obvious bug,
use `/docs-save-note` to record it. Notes go to `.agents/docs/private/` (gitignored). Use
`/docs-promote-notes` to promote valuable notes to `.agents/docs/shared/` (tracked in git).

## Quality Checklist

Before suggesting any commit:
- [ ] Code follows existing patterns in this codebase
- [ ] All relevant tests pass
- [ ] Types complete (if using typed language)
- [ ] No commented-out code
- [ ] No debug logging left behind
- [ ] Linting passes
- [ ] No security vulnerabilities introduced
- [ ] No secrets committed

## Security

- **NEVER** commit secrets, API keys, or passwords
- **ALWAYS** validate and sanitize user input
- **USE** parameterized queries (never string concatenation for SQL/commands)
{+ any project-specific security rules}

---

Write code as if the person maintaining it is a violent psychopath who knows where you live.

Keep it simple. Keep it tested. Keep it clean.
```

### 3.2 Generate CLAUDE.md (at project root)

```markdown
# CLAUDE.md

@AGENTS.md

## Claude Code Specific

### Skills (invoke with /command)
{List all skills in .agents/skills/ with their commands and one-line descriptions}

### Hooks
- **check-skill-sync** (PostToolUse): Warns when skills are created outside `.agents/skills/`
- **no-youre-right** (UserPromptSubmit): Prevents reflexive agreement — forces substantive analysis

Hooks only work in Claude Code and Gemini CLI. They are configured in `.claude/settings.json`.

### Agent System
Agent personas live in `.agents/agents/` organized by category. Skills spawn them as needed —
you don't need to load them manually.

### Knowledge Base
- `/docs-save-note` — Save knowledge to private (gitignored)
- `/docs-read-notes` — Browse notes
- `/docs-search-notes` — Search notes
- `/docs-promote-notes` — Promote private → shared (git-tracked)
```

### 3.3 Generate GEMINI.md (at project root)

```markdown
# GEMINI.md

@./AGENTS.md

## Gemini CLI Specific

### Skills (invoke with /command)
{Same skill list as CLAUDE.md}

### Hooks
- **check-skill-sync** (PostToolUse): Warns when skills are created outside `.agents/skills/`
- **no-youre-right** (UserPromptSubmit): Prevents reflexive agreement — forces substantive analysis

Hooks only work in Claude Code and Gemini CLI.

### Agent System
Agent personas live in `.agents/agents/` organized by category. Skills spawn them as needed.

### Knowledge Base
- `/docs-save-note` — Save knowledge to private (gitignored)
- `/docs-read-notes` — Browse notes
- `/docs-search-notes` — Search notes
- `/docs-promote-notes` — Promote private → shared (git-tracked)
```

### 3.4 Generate Cursor Rules (if requested)

Create `.cursor/rules/agents.mdc`:
```
---
description: Project development guide and AI agent instructions
alwaysApply: true
---

{Full AGENTS.md content pasted here — Cursor doesn't support @imports}
```

### 3.5 Generate Review Council Agents

Generate 8 agent personas in `.agents/agents/review/`, each tuned to the detected tech stack.
Read the current generic versions in `.agents/agents/review/*.md` as templates, then rewrite
each one with project-specific checklists:

- **security-auditor.md** — Use the actual ORM, infra provider, and framework XSS patterns
- **architecture-reviewer.md** — Use the actual architecture pattern and boundary rules
- **performance-reviewer.md** — Use the actual DB/ORM, framework, and runtime
- **patterns-reviewer.md** — Use the actual linter rules, framework conventions, naming patterns
- **code-simplifier.md** — Add framework-specific simplification hints
- **wheel-detector.md** — Use the actual runtime built-ins and installed dependencies
- **consistency-checker.md** — Use the actual file structure, naming, error handling, testing patterns
- **test-reviewer.md** — Use the actual test framework, test patterns, and conventions detected

### 3.6 Generate Housekeeping Agent

Rewrite `.agents/agents/housekeeping/repo-housekeeper.md` tuned to the actual directory
structure, naming conventions, config files, and build system.

### 3.7 Generate Architecture Doc

Create `.agents/docs/shared/architecture/project-overview.md` with:
- Project summary (from developer interview)
- Architecture pattern explanation
- Directory structure with annotations
- Key patterns and conventions
- Boundary rules or dependency direction rules

### 3.8 Generate/Update mcp.json

Update `.agents/mcp.json` based on integrations the developer requested. If none, leave empty.

### 3.9 Generate .claude/settings.json

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": ".agents/hooks/check-skill-sync.sh"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".agents/hooks/no-youre-right.sh"
          }
        ]
      }
    ]
  }
}
```

### 3.10 Migrate Existing Knowledge (conditional)

Only perform this step if the developer approved migration in Question Block 8. Skip if they chose "Skip" or if no knowledge was discovered.

For each approved source:

1. **Read the original file** and determine the best category:
   - ADRs, ARCHITECTURE.md, DESIGN.md → `architecture/`
   - CONTRIBUTING.md, CONVENTIONS.md, STYLE_GUIDE.md → `convention/`
   - Runbooks, playbooks, ONBOARDING.md, DEVELOPMENT.md → `tooling/`
   - Postmortems, incident reports, debugging guides → `debugging/`
   - Everything else → choose the most appropriate category

2. **Convert to standard note format** with YAML frontmatter:
   ```yaml
   ---
   tags:
     - migrated
     - {category}
     - {additional tags based on content}
   date: {today's date}
   source: migrated-from-{original-path}
   related: []
   ---
   ```

3. **Preserve the original content** below the frontmatter. Don't rewrite or summarize — just add structure. If the file already has YAML frontmatter, merge it with the standard fields.

4. **Write to `.agents/docs/shared/{category}/`** using a kebab-case filename derived from the original title or filename.

5. **Handle originals based on developer's choice:**
   - **Keep**: Leave originals in place. Inform the developer they now have duplicates.
   - **Remove**: Delete the original files after confirming each was successfully written. For directories that become empty after removal, delete the empty directory too. **Never remove README.md, CONTRIBUTING.md, or CHANGELOG.md** — these are conventional project root files that external tools and GitHub expect. Warn the developer and keep those in place.

After migration, report:
```
### Knowledge Migrated
- {N} files migrated to `.agents/docs/shared/`
- Categories: {list of categories used}
- Originals: {kept in place | removed}
{If removed: "- Deleted {N} original files. Empty directories cleaned up."}
{If kept: "- Original files preserved at their current locations."}
```

### 3.11 Update .gitignore

Append these entries to the project's `.gitignore` (or create one if it doesn't exist):
```gitignore
# AI agent tools — generated by .agents/update
.claude/
.gemini/
.cursor/
.mcp.json

# Agent knowledge base — private notes
.agents/docs/private/

# Obsidian config (generated when opening docs in Obsidian)
.agents/docs/.obsidian/
```

Do NOT add `CLAUDE.md`, `GEMINI.md`, or `AGENTS.md` to .gitignore — these should be committed.

---

## Phase 4: Distribute

After all files are generated:

1. Create the private docs directory structure:
   ```
   .agents/docs/private/debugging/
   .agents/docs/private/architecture/
   .agents/docs/private/tooling/
   .agents/docs/private/convention/
   .agents/docs/private/mistake/
   .agents/docs/private/preference/
   .agents/docs/private/_archive/
   ```

2. Run the update script to sync skills and MCP config to tool-specific directories:
   ```bash
   # Linux/macOS
   .agents/update.sh

   # Windows
   .agents/update.ps1
   ```

3. Report what was generated:

```
## Setup Complete

### Generated Files
- `AGENTS.md` — Canonical project instructions
- `CLAUDE.md` — Claude Code wrapper (@imports AGENTS.md)
- `GEMINI.md` — Gemini CLI wrapper (@imports AGENTS.md)
{- `.cursor/rules/agents.mdc` — Cursor rules (if requested)}
- `.claude/settings.json` — Hook configuration

### Generated Agents (tuned to your stack)
- `.agents/agents/review/security-auditor.md`
- `.agents/agents/review/architecture-reviewer.md`
- `.agents/agents/review/performance-reviewer.md`
- `.agents/agents/review/patterns-reviewer.md`
- `.agents/agents/review/code-simplifier.md`
- `.agents/agents/review/wheel-detector.md`
- `.agents/agents/review/consistency-checker.md`
- `.agents/agents/housekeeping/repo-housekeeper.md`

### Generated Docs
- `.agents/docs/shared/architecture/project-overview.md`

### Distributed (by update script)
- Skills → `.claude/skills/`, `.gemini/skills/`
- MCP config → `.mcp.json`, `.cursor/mcp.json`

### Next Steps
1. Review the generated files — especially `AGENTS.md` and the agent personas
2. Commit everything to git
3. Run `/review-council` on your next code change to test the review agents
4. Use `/docs-save-note` to start building your knowledge base
5. Run `/setup-update` anytime you make major stack changes
```

---

## Rules

- ALWAYS read existing CLAUDE.md/GEMINI.md/AGENTS.md before generating — incorporate existing rules
- NEVER overwrite existing files without showing the user what will change and getting approval
- NEVER guess at tech stack details — confirm with the developer if unsure
- NEVER skip the developer interview — the scan provides data, the interview provides intent
- Keep generated AGENTS.md under 200 lines — concise is better than comprehensive
- Agent personas should be actionable checklists, not essays
- If the developer answers "I don't know" or skips a question, use sensible defaults based on the scan
