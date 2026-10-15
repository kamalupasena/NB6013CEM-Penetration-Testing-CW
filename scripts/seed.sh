#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source ./scripts/lab-ports.sh
docker compose up -d --wait vehicle_db bank_db vehicle_api bank_api
node tests/integration/smoke.mjs --seed-only
