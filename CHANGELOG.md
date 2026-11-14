# Changelog

Each entry is one version of this Railway template. Breaking changes are listed first.
Read the entry before you apply an update in Railway.

## 2.12.0-1 (2026-11-12)

- First version: Homarr 2.12.0 (`ghcr.io/homarr-labs/homarr:v2.12.0@sha256:44c480afe9df57ce9de44cb664aec53199ea19926ebdd4e590c7b2c2c0a5ef79`).
- On the first start, creates an `admin` user with the password from `HOMARR_ADMIN_PASSWORD`, so a fresh deploy can't be claimed by the first visitor.
- nginx listens on Railway's `PORT`; Docker discovery is off (`ENABLE_DOCKER=false`).

## Unreleased

- README: Deploy on Railway button. No change to the running service.
- Removed `railway.json`: Railway no longer reads it (Config as Code is deprecated). The health check `/api/health/live` and the restart policy are now on the template's service config. No change to the running service.
