#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source ./scripts/lab-ports.sh
command -v docker >/dev/null || { echo 'Docker is required' >&2; exit 1; }
command -v node >/dev/null || { echo 'Node.js 20+ is required for verification' >&2; exit 1; }
docker compose version >/dev/null || { echo 'Docker Compose v2 is required' >&2; exit 1; }
docker info >/dev/null || { echo 'Docker daemon is unavailable' >&2; exit 1; }
for spec in "juice_web:${JUICE_PORT:-3000}" "vehicle_web:${VEHICLE_PORT:-8081}" "bank_web:${BANK_PORT:-8082}"; do
  service="${spec%%:*}"
  port="${spec##*:}"
  if [[ -n "$(docker compose ps --status running -q "$service" 2>/dev/null)" ]]; then continue; fi
  if command -v lsof >/dev/null && lsof -nP -iTCP:"$port" -sTCP:LISTEN | tail -n +2 | grep -q .; then
    echo "Port $port is already in use" >&2; exit 1
  fi
done
docker compose config --quiet
docker compose up -d --build --wait
./scripts/verify.sh --read-only
echo "Juice Shop: http://127.0.0.1:${JUICE_PORT:-3000}"
echo "Northstar Vehicle Care: http://127.0.0.1:${VEHICLE_PORT:-8081}"
echo "SecureBank: http://127.0.0.1:${BANK_PORT:-8082}"
