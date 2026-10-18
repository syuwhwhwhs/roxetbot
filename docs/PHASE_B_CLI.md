# Phase B — Global CLI (`roxet`)

**Scope:** Global operations CLI only. Database behavior unchanged from Phase A.  
**Out of scope:** permissions, identity sync, PasarGuard admin logic, node management.

---

## Installation

From the project root (requires sudo once):

```bash
sudo bash scripts/install_global_cli.sh
# or explicitly:
sudo bash scripts/install_global_cli.sh /path/to/RoXeT BoT
```

This writes:

| Path | Purpose |
|------|---------|
| `/usr/local/bin/roxet` | Global command |
| `/usr/local/lib/roxetbot/install_root` | Absolute install path |
| `/usr/local/lib/roxetbot/ctl` | (via install helper) constrained systemctl verbs |

`bash roxet.sh install` / systemd install also refreshes the global CLI.

Without sudo, from the repo:

```bash
export ROXET_HOME=/path/to/RoXeT BoT
./scripts/roxet status
# or
.venv/bin/python -m app.cli status
```

---

## Commands

```bash
roxet status
roxet start
roxet stop
roxet restart
roxet logs              # last 100 lines
roxet logs -f           # follow
roxet logs -n 200
roxet health
roxet backup [--note TEXT] [--no-env]
roxet backup --list
roxet restore <backup_id> [--yes] [--env] [--no-restart]
roxet migrate                    # alembic upgrade head
roxet migrate --from-sqlite --source 'sqlite+aiosqlite:///…' --target 'postgresql+asyncpg://…' -y
roxet doctor
```

Optional: `roxet --root /path/to/install status`

---

## Examples

```bash
roxet doctor
roxet status
roxet backup --note "pre-update"
roxet restore 20260804-120030-4745d007 --yes --no-restart
roxet migrate
roxet restart
roxet health
```

---

## Tests

```bash
.venv/bin/python -m pytest tests/test_phase_b_cli.py -q
```

---

## Final verification (Phase B complete)

```text
Fresh shell (env -i) from random dir → roxet status OK (resolves install_root)
Service detect: status shows roxetbot (active|inactive); start/stop/restart OK
  (verified with systemctl shim — this agent host has no systemd PID 1)
Health against live panel → /health {"ok": true}
Failure messages: unknown cmd exit 2; bad restore id / migrate usage exit 1 with clear text
backup.py unchanged in Phase B (diff vs Phase A tip = 0); CLI wraps create_backup/restore_backup
```
