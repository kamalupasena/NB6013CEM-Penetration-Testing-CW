#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source ./scripts/lab-ports.sh
if [[ "${1:-}" != '--yes' ]]; then
  read -r -p 'Reset all synthetic lab data in this Compose project? Type RESET: ' answer
  [[ "$answer" == 'RESET' ]] || { echo 'Cancelled'; exit 1; }
fi
docker compose down
docker volume rm coursework-lab_vehicle_data coursework-lab_bank_data
docker compose up -d --build --wait
./scripts/verify.sh --read-only
echo 'Synthetic data restored.'
