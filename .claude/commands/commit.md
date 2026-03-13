---
description: Review changes, gate commits by quality, and record follow-up tasks
argument-hint: [FILES=<paths>] [MSG="<commit message>"]
---

You are a careful code reviewer and commit gatekeeper.

Your job in this command is:

1. **Understand the change set**
   - If `FILES` is provided, focus your review on those paths.
   - Otherwise, assume the currently staged changes are the scope.
   - Infer the intent of the change and summarize it briefly for the user.

2. **Review before committing**
   - Perform a structured review of the diff:
     - correctness (bugs, logic errors, missing edge cases)
     - tests (missing or insufficient coverage)
     - design (architecture, cohesion, coupling, clarity)
     - style (readability, consistency with existing patterns)
   - Clearly separate findings into:
     - **BLOCKING issues** (must be addressed before committing)
     - **NON-BLOCKING improvements** (can be postponed / cleaned up later)

3. **If there is ANY BLOCKING issue**
   - **Do NOT run `git commit`.**
   - Do **not** modify any files in this command.
   - Output a concise report that includes:
     - a short summary of the overall change
     - a list of BLOCKING issues, each with:
       - file path
       - approximate line number(s)
       - short description of the problem
     - optionally, a list of NON-BLOCKING improvements for the user’s reference.
   - Explicitly state that the commit was **not** created.

4. **If there are NO BLOCKING issues**
   - It is safe to commit.
   - Do **not** modify any files in this command.
   - Commit message:
     - If `MSG` is provided, use it as the commit message.
     - Otherwise, construct a clear and concise message describing the change.
   - Staging rules:
     - If `FILES` is provided, conceptually stage them first: `$FILES`.
     - Only commit staged changes; **never** suggest `git add .` or `git commit -a`.
   - Do **not** interact with remotes (no `git push`).
   - Output:
     - a brief summary of what is being committed
     - the exact git command that the user can run.
   - For multi-line commit messages, use HEREDOC format with these **strict rules**:
     - Use `<<'EOF'` (single-quoted to prevent variable expansion)
     - The closing `EOF` must be at the **beginning of the line** with **no leading spaces, tabs, or trailing whitespace**
     - Commit message body must also have **no leading indentation**
     - **IMPORTANT**: When outputting the command, do NOT indent the HEREDOC content or EOF delimiter, even if surrounding text is indented

Example HEREDOC command (copy exactly as shown, no indentation):

```bash
git add file1.rb file2.rb && \
git commit -m "$(cat <<'EOF'
Short summary line

- Detail point 1
- Detail point 2

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

5. **General rules**
   - Never push or interact with remotes in this command (no `git push`).
   - During code review, prioritize collaborating with available Codex MCP tools.
     - When static analysis of diffs or detailed findings are needed, call Codex MCP review tools and reference their results.
     - However, this command (Claude Code) is responsible for the final BLOCKING / NON-BLOCKING judgment and report.
   - If any NON-BLOCKING items are found, write them to `.design/non-blocking-issues.md`.
   - Do not perform refactors here; only **review and gate commits**.
   - Do **not** create or update any task or refactor tracking files.
   - Keep your explanations short but precise, optimized for an experienced engineer.

6. **Design rules awareness**
   - Before deciding whether the changes are acceptable, check the relevant design documents if needed:
     - `.design/architecture.md`
     - `.design/guidelines.md`
     - `.design/decisions.md`
   - Verify that the changes do NOT violate:
     - layered architecture (e.g., controller → service → repository)
     - naming and dependency rules
     - domain invariants and constraints
     - any forbidden patterns listed in the guidelines
   - If you detect a design violation:
     - Treat it as a **BLOCKING issue** and do NOT commit.
     - Report it clearly in your BLOCKING issues list with context and affected files.
