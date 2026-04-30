---
name: pr
description: Create a GitHub pull request for the current branch. Use when the user asks to create a PR, open a pull request, or submit changes for review.
disable-model-invocation: true
allowed-tools: Bash(git *) Bash(gh *)
---

Create a pull request for the current branch:

1. Run `git status` to confirm there are no uncommitted changes
2. Run `git log main..HEAD --oneline` to summarize commits included in the PR
3. Run `git diff main...HEAD` to understand all changes
4. Push the branch if needed: `git push -u origin <branch>`
5. Create the PR with `gh pr create`:

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
- <bullet points describing what changed and why>

## Test plan
- [ ] <how to verify the change works>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

**PR title rules:**
- Under 70 characters
- Conventional Commits format: `feat: ...`, `fix: ...`, etc.
- Describes the "what", body describes the "why"

Return the PR URL when done.

$ARGUMENTS
