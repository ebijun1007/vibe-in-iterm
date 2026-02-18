---
name: task-intake
description: Create and update task tickets in `.design/tasks` as source-of-truth, and create/update matching vibe-kanban cards in the same timing (タスク/起票/issue/kanban同期).
---

# Task Intake

## Workflow

1. Confirm whether this is a new task or an update to an existing task.
2. Read `.design/tasks/README.md` for the format.
3. Decide `owner` with `.codex/AGENTS.md` triage rules (`codex` or `claude-code`).
4. Draft or update the task file under `.design/tasks/`.
   - Naming: `YYYYMMDD-short-slug.md` (lowercase, hyphen).
   - Fill every section, including `owner` and `## vibe-kanban同期`.
5. In the same timing, create/update the matching card in vibe-kanban MCP.
   - Follow `references/vibe-kanban-mcp.md` exactly.
   - Use execution forms in `references/vibe-kanban-execution-template.md`.
   - Persist returned card ID into `## vibe-kanban同期`.
6. If critical fields are missing (summary, desired behavior, acceptance criteria, test plan), ask targeted questions.
7. Do not edit implementation code unless the user explicitly requests it.

## MCP call rules (required)

1. Resolve project first:
   - Call `list_projects`.
   - Match project name with current directory basename (`pwd`).
   - If no exact match, stop and ask user.
2. Create or update task card:
   - If task file has card ID: call `get_task` then `update_task`.
   - If card ID is missing: call `create_task`, then write the returned ID.
3. Attempt start:
   - Use `start_workspace_session` only when user asked to start implementation.
   - `executor` must be selected from task `owner` (`codex` or `claude-code`).
   - Collect `repos` from `list_repos`.
4. Status handling:
   - Do not guess unknown status strings.
   - Use only values observed from existing `list_tasks`/`get_task` results in the same project.
   - If mapping cannot be determined, sync title/description only and ask user.

## Quality bar

- Make the task self-contained for another agent with no extra context.
- Include current vs desired behavior, scope, constraints, dependencies, acceptance criteria, and tests.
- Keep it concise and ASCII-only unless the file already uses non-ASCII.
- `.design/tasks` is source-of-truth. If mismatch with vibe-kanban is found, update vibe-kanban to match `.design/tasks`.

## Notes

- For multiple tasks, create one file per task.
- When updating a task, preserve history and only change the relevant fields.
- If vibe-kanban sync fails, mark `同期状態: error` and report the reason immediately.
- For operator consistency, always fill and follow `references/vibe-kanban-execution-template.md`.
