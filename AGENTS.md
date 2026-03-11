# AGENTS.md

This project uses the `.agents/` system for AI agent configuration.

**Run `/setup-init` to configure this project.** The setup will scan your codebase,
ask you questions about your architecture and preferences, and generate project-specific
configuration for Claude Code, Gemini CLI, Cursor, and Codex.

## CARDINAL RULE — NO IRREVERSIBLE CHANGES

**NEVER make irreversible changes without explicit permission:**

- **NEVER** commit or push changes to git — the human must review all code before committing
- **NEVER** install, add, or remove packages/dependencies without explicit user approval
- **NEVER** run database migrations, drops, or destructive operations without explicit user approval
- **NEVER** deploy, apply infrastructure changes, or mutate remote/production state without explicit user approval
- **NEVER** delete important files, production data, or anything not tracked by git without explicit user approval
- **NEVER** make ANY change that cannot be completely undone by running `git checkout .`

### Safety Protocol
1. **Before ANY potentially destructive operation**, ASK first.
2. **Safe operations (no permission needed):**
   - Reading files
   - Editing source files tracked by git
   - Running read-only queries
   - Running tests
   - Searching and grepping
   - Building (compile/bundle)

Until `/setup-init` is run, these cardinal rules apply. All other configuration will be
generated during setup.

---

Write code as if the person maintaining it is a violent psychopath who knows where you live.

Keep it simple. Keep it tested. Keep it clean.
