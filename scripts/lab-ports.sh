#!/usr/bin/env bash
if [[ -f .env ]]; then
  while IFS='=' read -r key value; do
    case "$key" in
      JUICE_PORT|VEHICLE_PORT|BANK_PORT)
        if [[ -z "${!key:-}" && "$value" =~ ^[0-9]+$ ]]; then export "$key=$value"; fi
        ;;
    esac
  done < .env
fi
