# Student setup

This is a private coursework environment. Use only the three lab URLs supplied by your instructor. Do not scan or test any other host, service, or account. All data is fictional; do not enter real credentials, personal information, or financial details.

## Local access

If running your own copy, install Docker Desktop or Docker Engine with Compose v2 and Node.js 20 or later, extract the student archive, and run:

```sh
cp .env.example .env
./scripts/deploy.sh
```

Open:

- OWASP Juice Shop: `http://127.0.0.1:3000`
- Northstar Vehicle Care: `http://127.0.0.1:8081`
- SecureBank: `http://127.0.0.1:8082`

If one of the default ports is in use, set `VEHICLE_PORT`, `BANK_PORT`, or `JUICE_PORT` in `.env` before deployment and use the corresponding local URL.

You can register your own customer account in either custom app. Sample customer accounts are `maya@vehicle.test`, `leo@vehicle.test`, `elena@securebank.test`, and `marcus@securebank.test`; each initially uses `Welcome123!`. Your instructor may provide a different credential sheet for a shared classroom deployment.

To stop the local lab, run `docker compose down`. To discard local changes and restore seed data, run `./scripts/reset.sh --yes`. This removes only the lab's two named data volumes. Preserve your evidence before resetting.
