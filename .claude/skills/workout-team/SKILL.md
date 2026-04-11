---
name: workout-team
description: Spawn the Social Workout agent team — a `backend` teammate and a `mobile` teammate. Does a tiny pre-flight (verify agents exist, peek at the dev SQLite DB) before spawning. Use when the user says "/workout-team", "start workout team", "spawn workout team", or "workout team".
allowed-tools: [Bash, Read, Glob]
context: inherit
---

# /workout-team — spawn the Social Workout agent team

You are the **team lead**. This skill turns the current session into an agent team with two teammates — one for the backend / database side, one for the Flutter app — and does a tiny pre-flight first.

The Social Workout repo is much earlier-stage than Sendi: there is no docker-compose, no `flutter run`, no device matrix to manage. Pre-flight is therefore intentionally minimal — verify the agent definitions exist, peek at the dev SQLite DB, then spawn.

## Prerequisites (check silently, fail loudly)

- Agent teams must be enabled: the user's `~/.claude.json` has `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS: "1"` in `env` and `teammateMode: "tmux"`. If a spawn later fails because teams aren't enabled, say so plainly — don't retry.
- Claude Code ≥ **v2.1.32**. (You can't easily check this at runtime; just know the failure mode and explain it if spawning fails.)
- The two teammate subagent definitions must exist:
  - `/Users/jorgen/github/devda/social_workout/.claude/agents/backend.md` → teammate type `backend`
  - `/Users/jorgen/github/devda/social_workout/.claude/agents/mobile.md` → teammate type `mobile`

  If either file is missing, **stop** and tell the user — don't silently inline the instructions.

## Step 1 — Pre-flight

Run these in **parallel** to classify the current state:

```bash
# Agent definitions present?
ls /Users/jorgen/github/devda/social_workout/.claude/agents/backend.md
ls /Users/jorgen/github/devda/social_workout/.claude/agents/mobile.md

# Dev SQLite DB present and readable?
ls -lh /Users/jorgen/github/devda/social_workout/sqlite/test-db.db 2>&1 || true

# ULID generator binary built?
ls /Users/jorgen/github/devda/social_workout/tools/generate_ulid/ulid 2>&1 || true

# Backend and mobile folders — populated yet, or still stubs?
ls -A /Users/jorgen/github/devda/social_workout/backend 2>&1
ls -A /Users/jorgen/github/devda/social_workout/mobile 2>&1
```

Classify:

- **DB = READY** iff `sqlite/test-db.db` exists. **DB = MISSING** otherwise.
- **ULID tool = BUILT** iff `tools/generate_ulid/ulid` exists. **NOT BUILT** otherwise.
- **Backend stub** iff `backend/` is empty. Otherwise **populated**.
- **Mobile stub** iff `mobile/` is empty. Otherwise **populated**.

Show the user a terse status block before spawning:

```
Workout team — pre-flight
  agents      ✓ backend.md, mobile.md
  sqlite db   ✓ test-db.db (<size>)        or    ✗ missing — run `make new-db-with-test-data`
  ulid tool   ✓ tools/generate_ulid/ulid   or    ✗ not built — run `just build-ulid`
  backend/    <stub | populated>
  mobile/     <stub | populated>
```

**Do not** boot, build, or rebuild anything in pre-flight. If the dev DB is missing or the ULID tool isn't built, just *report* it and let the team decide whether to fix it as part of the user's actual task. The Sendi skill boots docker compose because Sendi has a real running stack; this project doesn't yet.

## Step 2 — Spawn the agent team

Now create the team. Use the **existing subagent definitions** — don't inline or duplicate their instructions.

Spawn two teammates, named exactly `backend` and `mobile`:

- **`backend`** — teammate type from `.claude/agents/backend.md`. Owns `backend/`, `sqlite/`, `sqlite_migrations/`, and `tools/`. Initial stance: "Schema and tooling are <state>. Ready and standing by for the user's request."
- **`mobile`** — teammate type from `.claude/agents/mobile.md`. Owns `mobile/`. Initial stance: "Mobile app is <stub / populated>. Ready and standing by for the user's request."

Spawn them by telling Claude Code (natural-language) to create an agent team. Example prompt you can adapt:

> Create an agent team with two teammates. Spawn one teammate named `backend` using the `backend` subagent type, and one teammate named `mobile` using the `mobile` subagent type.
>
> Context for both teammates: the Social Workout repo is at `/Users/jorgen/github/devda/social_workout`. The dev SQLite DB is <ready / missing>, the ULID generator binary is <built / not built>, and the `backend/` and `mobile/` folders are <stubs / populated>. Each teammate owns its respective area and should read its canon files on first use.
>
> Initial task: none. Both teammates should briefly confirm their setup (one sentence each) and then stand by. **Do not begin implementation work** until the user gives a concrete task through the lead.

**Hard rules on the team shape:**

- Exactly **two** teammates. Don't invent more. This is a dedicated pair, not a pool.
- Don't pass the lead's conversation history to teammates — they don't inherit it. Include any task-specific context in the spawn prompt.
- Don't set per-teammate permission modes at spawn time — the docs call out that's not supported. Teammates inherit the lead's mode.
- **One team per session.** If the lead already has an active team, don't try to spawn another — tell the user to clean up the existing team first.

## Step 3 — Report back

Print a compact ready block and stop:

```
Workout team — ready
  ✓ agents       backend.md, mobile.md
  ✓ sqlite db    <ready (size) | missing>
  ✓ ulid tool    <built | not built>
  ✓ team         2 teammates: backend, mobile   (teammateMode=tmux)
  > interact     Shift+Down to cycle teammates in-process, or click a pane in split mode
  > next         Tell the lead what you want the team to work on
  > stop         'Clean up the team' (via the lead)
```

Do **not** hand the team a task of your own choosing. Wait for the user.

## Guardrails (apply at every step)

- **Never** destroy state: no `rm test-db.db`, no nuking `.claude/`, no rewriting `schema.sql` in pre-flight.
- **Never** rebuild the test DB or run migrations as part of pre-flight — that's a real task, not a setup step. Report missing state, don't fix it silently.
- **Never** duplicate the `backend`/`mobile` agent definitions inline — they live in `.claude/agents/` for a reason.
- **Never** spawn more than two teammates. If the user wants additional specialists, they can ask the lead for them by name after the initial spawn.

## Reference

- Agent teams docs: https://code.claude.com/docs/en/agent-teams
- Teammate definitions:
  - `.claude/agents/backend.md`
  - `.claude/agents/mobile.md`
- Repo overview: `README.md`, `plan.md`, `database_schema_review.md`
- DB scripts: `sqlite/db.sh`, `sqlite/test-db.sh`, `sqlite/generate-new-test-data.sh`, `Makefile`, `Justfile`
