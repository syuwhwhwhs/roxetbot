"""Deployment-platform detection (Railway).

Everything here is a no-op on a normal VPS/systemd install; behaviour only
changes when the process runs on Railway (or ``ROXET_PLATFORM=railway``).
"""

from __future__ import annotations

import os
from pathlib import Path


def _env(name: str) -> str:
    return (os.environ.get(name) or "").strip()


IS_RAILWAY: bool = bool(
    _env("RAILWAY_ENVIRONMENT")
    or _env("RAILWAY_ENVIRONMENT_NAME")
    or _env("RAILWAY_PROJECT_ID")
    or _env("RAILWAY_SERVICE_ID")
    or _env("ROXET_PLATFORM").lower() == "railway"
)

RAILWAY_UPDATE_MESSAGE = (
    "روی Railway آپدیت از داخل پنل انجام نمی‌شود؛ تغییرات را به گیت‌هاب push کنید "
    "تا Railway خودکار دیپلوی کند."
)
RAILWAY_TLS_MESSAGE = (
    "روی Railway گواهی HTTPS را خود Railway مدیریت می‌کند "
    "(دامنهٔ railway.app یا دامنهٔ اختصاصی در Settings → Networking)."
)


def railway_public_url() -> str:
    """https://<domain> from Railway's generated/custom domain, or ''."""
    dom = _env("RAILWAY_PUBLIC_DOMAIN").strip("/")
    if not dom:
        return ""
    return dom if "://" in dom else f"https://{dom}"


def data_dir_override() -> Path | None:
    """Persistent data dir: ROXET_DATA_DIR, else the attached Railway volume."""
    raw = _env("ROXET_DATA_DIR") or _env("RAILWAY_VOLUME_MOUNT_PATH")
    if not raw:
        return None
    return Path(raw).expanduser()


def update_checks_disabled() -> bool:
    """Railway redeploys from git; remote update checks only make sense for a fork repo."""
    return IS_RAILWAY and not _env("ROXET_GITHUB_REPO")
