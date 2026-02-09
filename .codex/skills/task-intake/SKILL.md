---
name: task-intake
description: Create and update task tickets in `.design/tasks` using the task template; use when the user asks to create or track tasks, issues, TODOs, or work items (タスク/起票/issue).
---

# Task Intake

## Workflow

1. Confirm whether this is a new task or an update to an existing task.
2. Read `.design/tasks/README.md` and `.design/tasks/TEMPLATE.md` for the format.
3. Draft or update the task file under `.design/tasks/`.
   - Naming: `YYYYMMDD-short-slug.md` (lowercase, hyphen).
   - Fill every section; use `TBD` only when the user cannot provide details.
4. If critical fields are missing (summary, desired behavior, acceptance criteria, test plan), ask targeted questions.
5. Do not edit implementation code unless the user explicitly requests it.

## Quality bar

- Make the task self-contained for another agent with no extra context.
- Include current vs desired behavior, scope, constraints, dependencies, acceptance criteria, and tests.
- Keep it concise and ASCII-only unless the file already uses non-ASCII.

## Notes

- For multiple tasks, create one file per task.
- When updating a task, preserve history and only change the relevant fields.
