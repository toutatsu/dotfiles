# Global Claude Code Instructions

## Token Efficiency

### Subagent Usage
- Do NOT spawn subagents for simple, single-step tasks (file reads, quick searches, small edits).
- Spawn subagents only when tasks are genuinely independent and can run in parallel to save wall-clock time.
- Prefer direct tool calls (Read, Grep, Bash) over spawning an Explore or general-purpose agent for targeted lookups.
- When spawning subagents, instruct them to return concise summaries only — not raw tool output.
- Never nest subagents (subagents cannot spawn further subagents).

### Context Management
- Run `/compact` at natural breakpoints (after a task completes, before starting a new one), not only when forced or near the limit.
- Prefer the Explore subagent (uses Haiku — cheaper) over general-purpose agents for codebase exploration.

### CLAUDE.md Files
- Keep CLAUDE.md files under 200 lines. Beyond that, compliance drops and token cost rises.
- Move path-specific rules to `.claude/rules/` with `paths` frontmatter so they load only when relevant files are edited.

## Response Style
- Keep responses concise. No trailing summaries of what was just done.
- No multi-paragraph docstrings or explanatory comment blocks in code.
