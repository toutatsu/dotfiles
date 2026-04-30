# Deep Agents — Global Instructions

## Language

Always respond in Japanese. Technical terms and code identifiers remain in their original form.

## Response Style

- Keep responses concise. No trailing summaries of what was just done.
- No multi-paragraph docstrings or explanatory comment blocks in code.

## Code Style

- Default to writing no comments. Only add one when the WHY is non-obvious.
- Don't add features, refactor, or introduce abstractions beyond what the task requires.
- Don't add error handling for scenarios that can't happen.

## Git

- Use Conventional Commits format: `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`, `test:`
- Keep commit messages concise — describe the "why", not just the "what"
