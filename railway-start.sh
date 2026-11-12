#!/bin/bash
# Railway start script for Homarr. Runs before the image's own entrypoint.
set -e
cd /app
P="${PORT:-7575}"
# nginx (public) listens on Railway's PORT; Next.js stays on its internal 3000.
sed -i "s/7575/${P}/g" /etc/nginx/templates/nginx.conf /app/run.sh
unset PORT
export ENABLE_DOCKER="${ENABLE_DOCKER:-false}"
U="${HOMARR_ADMIN_USERNAME:-admin}"
mkdir -p /appdata/db /appdata/redis /appdata/trusted-certificates
echo "Running DB migrations"
DISABLE_REDIS_LOGS=true node ./db/migrations/sqlite/migrate.cjs ./db/migrations/sqlite
export DB_MIGRATIONS_DISABLED=true
if [ ! -f /appdata/.railway-admin-created ]; then
  if [ -z "$HOMARR_ADMIN_PASSWORD" ]; then echo "HOMARR_ADMIN_PASSWORD is not set, refusing to start without an admin"; exit 1; fi
  # The CLI needs Redis; run a temporary one until the real start below.
  redis-server /app/redis.conf --protected-mode yes --daemonize yes >/dev/null
  sleep 1
  # The homarr CLI finishes its work but does not exit, so stop it once it has printed a result.
  cli() { pat="$1"; shift; f=$(mktemp); timeout 60 homarr "$@" >"$f" 2>&1 & p=$!
    for i in $(seq 1 60); do grep -q -E "$pat" "$f" && break; kill -0 "$p" 2>/dev/null || break; sleep 1; done
    sleep 1; kill "$p" 2>/dev/null || true; wait "$p" 2>/dev/null || true; cat "$f"; rm -f "$f"; }
  OUT=$(cli "Group:|exists|rror" recreate-admin -u "$U")
  echo "$OUT" | grep -v -i "password" | grep -v -i punycode | grep -v trace-deprecation || true
  G=$(echo "$OUT" | sed -n 's/^[[:space:]]*Group: //p')
  OUT=$(cli "updated successfully|not found|rror" users update-password -u "$U" -p "$HOMARR_ADMIN_PASSWORD")
  if echo "$OUT" | grep -q "Password updated successfully"; then
    [ -n "$G" ] && node -e 'const D=require("/app/node_modules/better-sqlite3");const d=new D(process.env.DB_URL);d.prepare("UPDATE \"group\" SET name=? WHERE id=?").run("admins",process.argv[1]);' "$G" 2>/dev/null || true
    touch /appdata/.railway-admin-created
    echo "Admin user '$U' created with the password from HOMARR_ADMIN_PASSWORD"
  else
    echo "Could not set the admin password"; redis-cli shutdown >/dev/null 2>&1; exit 1
  fi
  redis-cli shutdown >/dev/null 2>&1 || true
  sleep 1
fi
exec /app/entrypoint.sh sh run.sh
