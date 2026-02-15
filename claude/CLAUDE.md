# Sandbox Instructions

These are the default operating instructions for Claude in the sandbox. They apply to all projects.

---

## Team-First Development

For ANY research or development task, always create a multi-agent team. The minimum team composition for development work:

- **Engineer(s)**: One per domain being worked on (frontend, backend, infra, etc.). These agents write and own the code.
- **Product**: The voice of the customer. Makes product decisions, defines requirements, evaluates whether the output solves the right problem.
- **Design**: Evaluates quality of design (UI/UX, API ergonomics, developer experience). Suggests improvements and flags usability issues.
- **Architect**: Handles larger systems concerns - component boundaries, data flow, scalability, integration patterns. Owns the technical design.
- **Staff Engineer**: Reviews ALL work critically. Looks for correctness issues, edge cases, maintainability problems, and missed requirements. Acts as the quality gate.
- **Editor**: Reviews all documentation, comments, READMEs, and user-facing text for clarity, accuracy, and completeness.
- **Security Engineer**: Reviews and requests fixes for any security issues (from including stuff in repo that shouldn't be to vulnerabilities, poor design, etc.)

For research tasks, adapt the team composition to the task (e.g., multiple researcher agents for parallel investigation, a synthesizer to combine findings).

Do not just use sub agents - I expect you to always spawn and manage a team unless you strongly feel that a team is not warranted. In the case that you do not think a team is a good idea, tell me that you believe a team is not needed and why and ask for permission to continue alone or without a team.

## Plan Before Acting

Before any implementation work:

1. Draft a plan that covers scope, approach, key decisions, and expected deliverables.
2. Share the plan with the entire team for review.
3. Each team member weighs in from their perspective (product viability, design quality, architectural soundness, engineering feasibility, etc.).
4. Iterate on the plan until the full team has signed off.
5. Only then begin implementation.

Do not skip this step. A 20-minute planning discussion prevents hours of rework.

## Testing and Quality

All code that is produced must be tested and verified:

- **Unit tests**: Cover all new functions, methods, and modules. Test edge cases and error paths.
- **End-to-end tests**: Cover all user-facing flows and critical paths.
- **Linting**: Run all configured linters and fix violations before considering work done.
- **Static analysis**: Run static analysis tools appropriate to the language/framework and carefully read through the code, following flows of logic/data, ensuring that edge cases have not been missed. Fix all warnings and errors.

No code is "done" until tests pass, linters are clean, and static analysis is green.

## Project Notes (.claude-notes.md)

Every project must maintain a `.claude-notes.md` file in the project root. This file should contain everything a new team would need to pick up the project:

- Project purpose and goals
- Architecture overview and key design decisions
- Setup instructions and dependencies
- Current status and known issues
- Important context that isn't obvious from the code
- Links to relevant project descriptions, specs, or references

Update `.claude-notes.md` as you work - treat it as a living document, not an afterthought. Reference it at the start of every session and before major decisions to maintain continuity.

## Project Kickoff

At the start of every new major project:

1. Draft a **project description** collaboratively. This should cover the problem being solved, target users, success criteria, scope boundaries, and key constraints.
2. Save the project description in the repo as `project-<project_name>.md`.
3. Reference the project description throughout development to stay aligned on goals and scope. When in doubt about a decision, go back to the project description.

## Read-Only External Services

All external service integrations are **read-only**. You can search, read, and reference information but cannot create, modify, or delete data in any external service.

**Enforced via deny list** (Slack, Linear, Notion):
- Write tool calls are blocked in permissions settings
- Attempting to call a write tool will be denied

**Enforced via API** (GitHub, Google Workspace):
- GitHub uses a read-only fine-grained Personal Access Token (required -- not optional)
- Google Workspace uses read-only OAuth scopes (`gmail.readonly`, `drive.readonly`, `calendar.readonly`, `documents.readonly`)

If you need to create or modify data in an external service, ask the user to do it directly.
