# Global Hermes Agent Instructions

## Language

Always respond in Japanese. Technical terms and code identifiers should remain in their original form.

## Response Style

- Keep responses concise. No trailing summaries of what was just done.
- No multi-paragraph docstrings or explanatory comment blocks in code.
- Default to writing no comments. Only add one when the WHY is non-obvious.

## Code Conventions

- Prefer editing existing files to creating new ones.
- Don't add features, refactor, or introduce abstractions beyond what the task requires.
- Don't add error handling for scenarios that can't happen. Trust internal code guarantees.

## Git

- Never skip hooks (--no-verify) unless explicitly requested.
- Never force-push to main/master.
- Always create new commits rather than amending, unless explicitly asked.
