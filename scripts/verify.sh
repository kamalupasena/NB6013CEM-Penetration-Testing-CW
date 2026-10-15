#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source ./scripts/lab-ports.sh
docker compose config --quiet
for service in juice_web vehicle_db vehicle_api vehicle_web bank_db bank_api bank_web; do
  id="$(docker compose ps -q "$service")"
  [[ -n "$id" ]] || { echo "$service is missing" >&2; exit 1; }
  state="$(docker inspect --format '{{.State.Health.Status}}' "$id")"
  [[ "$state" == healthy ]] || { echo "$service is $state" >&2; exit 1; }
done
for service in juice_web vehicle_web bank_web; do
  id="$(docker compose ps -q "$service")"
  docker inspect --format '{{json .HostConfig.PortBindings}}' "$id" | node -e 'let s="";process.stdin.on("data",x=>s+=x);process.stdin.on("end",()=>{const p=JSON.parse(s);for(const bindings of Object.values(p))for(const b of bindings)if(b.HostIp!=="127.0.0.1")process.exit(1)})' || { echo "$service has a non-local binding" >&2; exit 1; }
done
for service in vehicle_db bank_db vehicle_api bank_api; do
  id="$(docker compose ps -q "$service")"
  [[ "$(docker inspect --format '{{json .HostConfig.PortBindings}}' "$id")" == '{}' || "$(docker inspect --format '{{json .HostConfig.PortBindings}}' "$id")" == 'null' ]] || { echo "$service exposes a host port" >&2; exit 1; }
done
node --input-type=module -e 'import assert from "node:assert/strict"; const base=`http://127.0.0.1:${process.env.JUICE_PORT||3000}`; const page=await fetch(base); assert.equal(page.status,200); assert.match(await page.text(),/assessment-quiet\.js/); for(const path of ["/api/Challenges","/api/Hints"]){const result=await fetch(base+path);assert.equal(result.status,404,`${path} must be private`)} const config=await fetch(base+"/rest/admin/application-configuration");assert.equal(config.status,200);const data=await config.text();assert.doesNotMatch(data,/ForProductTamperingChallenge|ForCsrfChallenge|useForChristmasSpecialChallenge/);assert.equal(JSON.parse(data).config.challenges.showHints,false)'
if [[ "${1:-}" == '--read-only' ]]; then node tests/integration/smoke.mjs --seed-only; else node tests/integration/smoke.mjs; fi
for service in vehicle_web bank_web; do
  id="$(docker compose ps -q "$service")"
  if docker exec "$id" sh -c "find /usr/share/nginx/html -name '*.map' | grep -q ."; then echo "$service contains source maps" >&2; exit 1; fi
done
echo 'Health, isolation, workflows, seed data, and bundle inspection passed.'
