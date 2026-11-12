# Homarr on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/GSmCSk?utm_medium=integration&utm_source=button&utm_campaign=homarr)

Railway template for [Homarr](https://github.com/homarr-labs/homarr), a self-hosted dashboard for your servers and services.

## What it deploys

One service, **Homarr**, built from this repo's `Dockerfile`:

- Homarr **2.12.0**, the official image pinned by digest: `ghcr.io/homarr-labs/homarr:v2.12.0@sha256:44c480afe9df57ce9de44cb664aec53199ea19926ebdd4e590c7b2c2c0a5ef79`.
- A Railway volume at `/appdata` for the SQLite database, the internal Redis dump and trusted certificates.
- A Railway domain, health check `/api/health/live`, restart on failure (all in `railway.json`).

`railway-start.sh` runs before the image's own entrypoint. It moves nginx onto Railway's `PORT` (Next.js stays on its internal port 3000) and runs the database migrations. On the first start it creates an `admin` user with Homarr's own CLI, sets its password to `HOMARR_ADMIN_PASSWORD` and names its group `admins`. Without this step, a fresh Homarr lets whoever opens it first claim it. Docker discovery is off, because Railway has no Docker socket.

## Variables

| Variable | Default in the template | Description |
|---|---|---|
| `SECRET_ENCRYPTION_KEY` | `${{secret(64, "abcdef0123456789")}}` (generated) | 64-character hex key Homarr uses to encrypt integration secrets. Don't change it after the first deploy. |
| `HOMARR_ADMIN_PASSWORD` | `${{secret(24, "…")}}` (generated) | Password of the `admin` user created on the first start. Change it in Homarr afterwards; editing this variable later has no effect. |
| `BASE_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Public URL of this Homarr instance. |

**First login:** open the Railway URL and sign in as `admin` with `HOMARR_ADMIN_PASSWORD` (the service's Variables tab). Homarr then shows its setup page, which only a signed-in administrator can complete.

**Integrations:** integrations that talk to an app over HTTP (Jellyfin, Plex, the *arr apps, Pi-hole, Home Assistant and so on) work when Railway can reach that app. Services on a home network have to be exposed first. The Docker and Kubernetes widgets don't work on Railway.

## Updates

Projects deployed from the template build from this repo's `main` branch. When a new version is merged to `main`, Railway shows those projects an "update available" notice, and each owner chooses when to apply it. Every version is listed in [CHANGELOG.md](CHANGELOG.md), with breaking changes first.
