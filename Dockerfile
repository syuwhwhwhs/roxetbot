# RoXeT BoT — container image for Railway (works on any Docker host).
FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# pg_dump/pg_restore (panel backups) must be >= the server major version.
# Railway Postgres is recent, so use the PGDG client and fall back to Debian's.
ARG PG_CLIENT_VERSION=17

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl gnupg \
 && ( install -d /usr/share/postgresql-common/pgdg \
      && curl -fsSL -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc \
           https://www.postgresql.org/media/keys/ACCC4CF8.asc \
      && . /etc/os-release \
      && echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt ${VERSION_CODENAME}-pgdg main" \
           > /etc/apt/sources.list.d/pgdg.list \
      && apt-get update \
      && apt-get install -y --no-install-recommends "postgresql-client-${PG_CLIENT_VERSION}" ) \
    || apt-get install -y --no-install-recommends postgresql-client \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt ./
RUN pip install -r requirements.txt

COPY . .

# Railway: attach a Volume (any mount path). RAILWAY_VOLUME_MOUNT_PATH is read
# automatically; without a volume this folder is wiped on every redeploy.
RUN mkdir -p /app/data

# Railway injects PORT; the app binds to it (falls back to 9000 elsewhere).
EXPOSE 9000
CMD ["python", "run.py"]
