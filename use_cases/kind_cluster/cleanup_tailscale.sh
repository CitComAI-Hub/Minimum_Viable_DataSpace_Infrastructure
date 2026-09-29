#!/usr/bin/env bash
set -e

# Script base directory
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TFVARS_FILE="$DIR/apps/terraform.tfvars"

# Devices to remove: their exact Tailnet hostnames (with or without a -N suffix)
HOSTNAMES=("$@")
if [[ ${#HOSTNAMES[@]} -eq 0 ]]; then
  echo "Usage: $0 <hostname> [<hostname> ...]"
  exit 1
fi

CLIENT_ID="${TF_VAR_tailscale_oauth_client_id:-$TAILSCALE_CLIENT_ID}"
CLIENT_SECRET="${TF_VAR_tailscale_oauth_client_secret:-$TAILSCALE_CLIENT_SECRET}"

# If they are not in environment variables, read them from apps/terraform.tfvars
if [[ -z "$CLIENT_ID" || -z "$CLIENT_SECRET" ]] && [[ -f "$TFVARS_FILE" ]]; then
  CLIENT_ID=$(grep -E '^\s*tailscale_oauth_client_id\s*=' "$TFVARS_FILE" | head -1 | sed -E 's/.*=\s*"([^"]+)".*/\1/' || true)
  CLIENT_SECRET=$(grep -E '^\s*tailscale_oauth_client_secret\s*=' "$TFVARS_FILE" | head -1 | sed -E 's/.*=\s*"([^"]+)".*/\1/' || true)
fi

if [[ -z "$CLIENT_ID" || -z "$CLIENT_SECRET" || "$CLIENT_ID" == *"xxxxxx"* ]]; then
  echo "[Tailscale Cleanup] No valid credentials found in apps/terraform.tfvars. Skipping cleanup."
  exit 0
fi

echo "[Tailscale Cleanup] Requesting an access token from the Tailscale API..."
TOKEN_RESPONSE=$(curl -s -f -X POST "https://api.tailscale.com/api/v2/oauth/token" \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" 2>/dev/null || true)

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.access_token // empty')

if [[ -z "$ACCESS_TOKEN" ]]; then
  echo "[Tailscale Cleanup] Could not get an API token. Skipping cleanup."
  exit 0
fi

echo "[Tailscale Cleanup] Looking for devices: ${HOSTNAMES[*]}..."
DEVICES_JSON=$(curl -s -f -H "Authorization: Bearer $ACCESS_TOKEN" "https://api.tailscale.com/api/v2/tailnet/-/devices" 2>/dev/null || true)

if [[ -z "$DEVICES_JSON" ]]; then
  echo "[Tailscale Cleanup] Could not list devices."
  exit 0
fi

# Only devices tagged tag:k8s-operator whose MagicDNS name is one of HOSTNAMES,
# with or without the -N suffix Tailscale adds when a name is registered twice
HOSTNAMES_JSON=$(printf '%s\n' "${HOSTNAMES[@]}" | jq -R . | jq -s .)
TARGET_DEVICES=$(echo "$DEVICES_JSON" | jq -c --argjson hosts "$HOSTNAMES_JSON" '.devices[] | select(
  (.tags // [] | index("tag:k8s-operator") != null) and
  ((.name | split(".")[0] | sub("-[0-9]+$"; "")) as $h | $hosts | index($h) != null)
) | {id: .id, name: .name}')

if [[ -z "$TARGET_DEVICES" ]]; then
  echo "[Tailscale Cleanup] No orphaned devices to remove."
  exit 0
fi

while IFS= read -r dev; do
  DEV_ID=$(echo "$dev" | jq -r '.id')
  DEV_NAME=$(echo "$dev" | jq -r '.name')

  echo "[Tailscale Cleanup] Removing Tailnet device: $DEV_NAME (ID: $DEV_ID)..."
  DELETE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    "https://api.tailscale.com/api/v2/device/$DEV_ID" || true)

  if [[ "$DELETE_STATUS" == "200" || "$DELETE_STATUS" == "204" ]]; then
    echo "[Tailscale Cleanup] ✓ $DEV_NAME removed from Tailscale."
  else
    echo "[Tailscale Cleanup] ✗ Could not remove $DEV_NAME (HTTP $DELETE_STATUS)."
  fi
done <<< "$TARGET_DEVICES"

echo "[Tailscale Cleanup] Cleanup completed."
