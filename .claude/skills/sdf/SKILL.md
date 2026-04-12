---
name: sdf
description: "sdf parallel-worktree helper: write/edit .sdf.yaml configs AND boot the stack + spawn an agent team. Detects worktree context automatically. Triggers on: sdf, sdf.yaml, worktree create, parallel worktrees, port allocator, worktree hooks, sdf pr, pull request, start team, spawn team, boot team, sdf team."
allowed-tools: [Bash, Read, Glob]
context: inherit
---

# sdf — parallel-worktree helper

This skill has two modes. Activate the right one based on what the user is doing:

1. **Config mode** — the user is writing, editing, or debugging `.sdf.yaml`. Follow the "Config guide" sections below.
2. **Team mode** — the user wants to boot the dev stack and spawn an agent team. Follow the "Team guide" sections below.

If the user says something ambiguous, ask which they want.

---

# Config guide

Use this when the user is writing a fresh `.sdf.yaml`, editing an existing one, asking what a field does, debugging a hook failure, or migrating a project to `sdf`.

## Quick schema orientation

A `.sdf.yaml` has eight top-level keys, all optional except `project_name`:

- `project_name` — required. Docker-compose-safe name for generated compose project names.
- `copy` — files and directories copied from the main repo into each new worktree.
- `port_stride` — default port stride (how far ports advance per slot). Defaults to `10`.
- `ports` — named port declarations. Each port gets `base + slot * stride`.
- `pools` — named lists of opaque strings round-robined across worktrees.
- `env` — Go `text/template` strings rendered into `.env.worktree`.
- `hooks` — shell commands run around worktree lifecycle events (`post_create`, `pre_remove`).
- `pr` — configures `sdf pr create` behavior (base branch, body template).

Full reference: `cli/README.md` in the sdf repo.

## The schema in full

```yaml
# .sdf.yaml — paste at the repo root, edit per your project.

project_name: myapp         # required; must match [a-z0-9][a-z0-9_-]*.

copy:                       # optional. Missing files silently skipped.
  files:
    - .env
    - config/local.toml
  dirs:
    - .vscode
    - .idea

port_stride: 10             # default stride. Slot N → base + N*stride.

ports:                      # named port declarations.
  - name: APP_PORT          # must match [A-Z_][A-Z0-9_]*.
    base: 8080
  - name: DB_PORT
    base: 5432
  - name: DEBUG_PORT
    base: 40000
    stride: 5               # optional per-port override

pools:                      # optional; round-robin allocated.
  devices:
    - emulator-5554
    - emulator-5556
  fixtures:
    - fresh-snapshot-a
    - fresh-snapshot-b

env:                        # KEY=value → .env.worktree
  COMPOSE_PROJECT_NAME: "{{.ProjectName}}-{{.BranchSafe}}"

hooks:
  post_create:
    - echo "created {{.Branch}} at slot {{.Slot}}"
    - ./scripts/setup.sh
  pre_remove:
    - docker compose -p {{.ProjectName}}-{{.BranchSafe}} down

pr:                         # optional; configures `sdf pr create`.
  base: main
  body_template: |
    Worktree slot {{.Slot}}
```

## Template fields reference

| Key | Value | Example |
|---|---|---|
| `{{.ProjectName}}` | `project_name` from config | `myapp` |
| `{{.Branch}}` | Raw git branch name | `feature/foo` |
| `{{.BranchSafe}}` | Docker-Compose-sanitized branch | `feature-foo` |
| `{{.Slot}}` | Allocated slot (1, 2, …) | `1` |
| `{{.APP_PORT}}`, … | One key per declared port | `8090` |
| `{{.Pools.devices}}`, … | One key per declared pool | `emulator-5554` |

## How to populate a fresh `.sdf.yaml`

When a user says *"write a .sdf.yaml for my project"*, follow this recipe:

### Step 1. Project name
Ask: **"What's the project name?"** Must match `[a-z0-9][a-z0-9_-]*`.

### Step 2. Files and directories to copy
Ask: **"What files/dirs are not in git but needed per-worktree?"** Probe: `.env*`, `.vscode/`, `.idea/`, `.claude/settings*.json`, `config/local.*`. Check `.gitignore` for candidates.

### Step 3. Ports
Ask: **"What ports does your project listen on?"** Probe: `docker-compose.yml` ports, `Dockerfile` EXPOSE, Go `:NNNN` listen strings, `package.json` scripts. Name each port `UPPER_SNAKE_CASE`.

### Step 4. Compose project name
If Docker Compose is used, add: `env: { COMPOSE_PROJECT_NAME: "{{.ProjectName}}-{{.BranchSafe}}" }`

### Step 5. Pools (only if needed)
Ask: **"Any scarce one-per-worktree resources?"** (device IDs, DB snapshots, test fixtures). Most projects skip this.

### Step 6. Hooks
Ask: **"What should happen on worktree create/destroy?"** Common: start/stop Docker, run migrations, patch config files with sed, forward adb ports.

### Step 7. PR config
If the project uses GitHub, optionally add `pr: { base: main }`.

## Common patterns

### Docker Compose with per-worktree ports

**IMPORTANT: env file layering.** Docker Compose uses `--env-file` for
compose-level variable interpolation (`${APP_PORT:-8080}` in the YAML).
`.env.worktree` has port overrides but NOT database credentials or secrets.
Those typically live in a separate `.env` file (e.g. `web/.env`, `backend/.env`,
or `.env` at the repo root). You MUST pass BOTH files so compose has access
to everything:

```yaml
hooks:
  post_create:
    # --env-file order matters: first file provides base vars (DB creds etc.),
    # second file overrides ports. Later values win on duplicate keys.
    - "docker compose -f web/docker-compose.yml --env-file web/.env --env-file .env.worktree -p {{.ProjectName}}-{{.BranchSafe}} up -d"
  pre_remove:
    - "docker compose -p {{.ProjectName}}-{{.BranchSafe}} down"
```

**When helping the user write this hook**, always ask: **"Where does your
docker-compose.yml live, and where are your DB credentials / secrets stored?"**
Common patterns:
- `web/.env` or `backend/.env` — credentials in a subdirectory alongside the compose file
- `.env` at the repo root — credentials at the top level
- `docker-compose.yml` uses `env_file:` inside the YAML for container env — this is SEPARATE from `--env-file` on the CLI. The container-level `env_file:` paths are relative to the compose file's directory and load independently.

If the project has NO separate credentials file (everything is in env vars or
hardcoded), a single `--env-file .env.worktree` suffices. But always check —
missing DB passwords is the #1 failure mode for worktree Docker boot.

In the docker-compose.yml itself, parameterize host ports with defaults:
```yaml
services:
  app:
    ports:
      - "${APP_PORT:-8080}:8080"
  db:
    ports:
      - "${DB_PORT:-5432}:5432"
```

### Patch a config file with sed
```yaml
hooks:
  post_create:
    - sed -i.bak 's/"port": 40000/"port": {{.DEBUG_PORT}}/' .vscode/launch.json
    - rm -f .vscode/launch.json.bak
    # IMPORTANT: hide patched tracked files from git status in this worktree
    - git update-index --assume-unchanged .vscode/launch.json
```

**IMPORTANT: hiding patched tracked files from git.** When a `post_create`
hook patches a **tracked** file (like `.vscode/launch.json`), the worktree's
`git status` will show it as modified. Users will accidentally commit the
per-worktree port values back to the shared branch. Fix this with
`git update-index --assume-unchanged <file>` as the last hook step.

Key points:
- `.gitignore` does NOT work for tracked files — only for untracked ones.
- `.git/info/exclude` also only works for untracked files.
- `--assume-unchanged` tells git to stop checking the file in this worktree's
  index. It's per-worktree, so it doesn't affect the main repo.
- To undo (e.g., if the user intentionally wants to commit a port change):
  `git update-index --no-assume-unchanged <file>`

**When helping the user write sed hooks**, always add a matching
`git update-index --assume-unchanged` line for every tracked file that
gets patched. Group them into one command:
```yaml
    - git update-index --assume-unchanged web/.vscode/launch.json mobile/.vscode/launch.json
```

### Create a PR from a worktree
`sdf pr create` pushes the branch and opens a GitHub PR. Title auto-generated from branch name. Flags: `--draft`, `--fill`, `-t "title"`, `-b base`.

## Validation rules

- `project_name`: `[a-z0-9][a-z0-9_-]*`
- Port `name`: `[A-Z_][A-Z0-9_]*`, must not collide with reserved fields (`ProjectName`, `Branch`, `BranchSafe`, `Slot`, `Pools`)
- Pool `name`: `[a-z_][a-z0-9_]*`, same reserved-name check
- Copy paths: no `..`, no leading `/`
- `env:` and hook strings: parsed as Go templates at load time (syntax errors fail early)
- Slot 0 reserved for main; worktrees start at 1

## Hook environment quick-ref

| Template | Shell env var | Example |
|---|---|---|
| `{{.ProjectName}}` | `$PROJECT_NAME` | `myapp` |
| `{{.Branch}}` | `$BRANCH` | `feature/foo` |
| `{{.BranchSafe}}` | `$BRANCH_SAFE` | `feature-foo` |
| `{{.Slot}}` | `$SLOT` | `1` |
| `{{.APP_PORT}}` | `$APP_PORT` | `8090` |
| `{{.Pools.devices}}` | `$POOL_DEVICES` | `emulator-5554` |

## Debugging

- **Hook failure on create**: recovery block printed with worktree path, failing hook, and exact command. Worktree left on disk, not recorded in state. Fix cause → `git worktree remove --force` → `git branch -D` → retry.
- **Hook failure on pop**: worktree NOT removed. Fix and retry.
- **Port collision**: bump the `base:` or use per-port `stride:` override.

---

# Team guide

Use this when the user wants to boot the dev stack and spawn an agent team. Works from the main repo or from an sdf worktree.

## Step 0 — Detect context

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -f "$REPO_ROOT/.env.worktree" ]; then
  echo "=== WORKTREE MODE ==="
  cat "$REPO_ROOT/.env.worktree"
else
  echo "=== MAIN MODE ==="
fi
# What agents are available?
ls "$REPO_ROOT"/*/.claude/agents/*.md "$REPO_ROOT"/.claude/agents/*.md 2>/dev/null || true
```

**Worktree mode** (`.env.worktree` exists): source it for `APP_PORT`, `DB_PORT`, `COMPOSE_PROJECT_NAME`, `FLUTTER_DEVICE_ID`, etc.

**Main mode**: use defaults from `.sdf.yaml` port bases, or fall back to common defaults (8080, 5432).

## Step 1 — Pre-flight

```bash
docker compose ps --format json 2>/dev/null || true
nc -zv localhost $APP_PORT 2>&1 || true
pgrep -fl 'flutter run' 2>&1 || true
which flutter >/dev/null 2>&1 && flutter devices --machine 2>/dev/null || true
```

Show:
```
Team pre-flight (<worktree: branch slot N  OR  main>)
  backend     ✓ up (:$APP_PORT)   or   ✗ down
  mobile      ✓ running           or   ✗ not running   or   n/a
  devices     <list>              or   n/a
```

## Step 2 — Boot what's missing

**Backend** — only if a compose file exists:
- Worktree: find the compose file AND the credentials env file (e.g. `web/.env`, `backend/.env`, or `.env`). Pass both: `docker compose -f <compose-file> --env-file <creds-env> --env-file .env.worktree -p $COMPOSE_PROJECT_NAME up -d`. The creds file provides DB passwords etc., `.env.worktree` overrides the ports. **Missing this is the #1 failure mode** — always check for a separate `.env` file near the compose file.
- Main: `cd <compose-dir> && docker compose up -d` (auto-loads the local `.env`).
- Poll port ~15s. Never `down -v`, `prune`, `rmi`, or `--build` unless asked.

**Mobile** — only if a Flutter project exists:
- Worktree with `FLUTTER_DEVICE_ID`: use directly, don't ask.
- Main or no pre-assigned device: list connected devices, ask if multiple.
- Android: `adb reverse tcp:$APP_PORT tcp:$APP_PORT` first.
- Run in background (`run_in_background: true`).

## Step 3 — Discover and spawn teammates

Scan for agent definitions:
```bash
ls "$REPO_ROOT"/*/.claude/agents/*.md "$REPO_ROOT"/.claude/agents/*.md 2>/dev/null
```

Spawn one teammate per agent definition found. Include worktree context (ports, device, status) in each spawn prompt. Each teammate reads its own CLAUDE.md, confirms in one sentence, then stands by.

**Rules:**
- Don't invent teammates beyond what agent definitions exist.
- Don't inline agent definitions.
- One team per session.
- **Do not auto-start work.** Wait for the user.

## Step 4 — Report

```
Team — ready
  context     <worktree: branch slot N  OR  main repo>
  ✓ backend   <status>   :$APP_PORT
  ✓ mobile    <status>   device: $DEVICE_ID
  ✓ team      N teammates: <names>
  > next      Tell the lead what to work on
```

## Guardrails

- **Never** destroy state (no `-v`, no `prune`, no `--build`).
- **Never** silently pick a device when multiple are connected (unless worktree pre-assigned one).
- **Never** start Flutter in the foreground.
- **Never** loop on boot failures — show logs and stop.
- **Never** duplicate agent definitions inline.

---

# Further reading

Full CLI + schema reference: `cli/README.md` in the sdf repo.
