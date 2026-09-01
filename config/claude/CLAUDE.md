# Global Claude Code Instructions

## Token Efficiency

### Subagent Usage
- Do NOT spawn subagents for simple, single-step tasks (file reads, quick searches, small edits).
- Spawn subagents only when tasks are genuinely independent and can run in parallel to save wall-clock time.
- Prefer direct tool calls (Read, Grep, Bash) over spawning an Explore or general-purpose agent for targeted lookups.
- When spawning subagents, instruct them to return concise summaries only — not raw tool output.
- Avoid nesting subagents unless the task genuinely splits into parallel subtasks. Nesting is capped at 3 levels below the main conversation (`CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` to change).

### Context Management
- Claude cannot run `/compact` or `/clear` itself. At natural breakpoints, suggest whichever fits:
  - `/clear` — switching to unrelated work (stale context is pure waste). Suggest `/rename` first so the session can be found with `/resume`.
  - `/compact` — same task continues but history is bloated.
- Auto-compact is the overflow safety net, not the primary strategy. Manual compaction at a chosen breakpoint preserves better context.
- Delegate verbose operations (test runs, log processing, doc fetching) to subagents so only the summary enters the main context.
- Prefer the Explore subagent (uses Haiku — cheaper) over general-purpose agents for codebase exploration.

### CLAUDE.md Files
- Keep CLAUDE.md files under 200 lines. Beyond that, compliance drops and token cost rises.
- Move path-specific rules to `.claude/rules/` with `paths` frontmatter so they load only when relevant files are edited.

## Response Style
Tone and length are handled by the built-in `Concise` output style (`outputStyle` in settings.json). Only project-specific rules belong here:
- No multi-paragraph docstrings or explanatory comment blocks in code.

## Compact Instructions

When compacting, prioritize: the user's original goal and constraints, decisions made and their rationale, file paths and code changes already applied, and unresolved issues. Drop verbose tool output and superseded exploration.
