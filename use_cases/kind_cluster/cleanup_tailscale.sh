#!/usr/bin/env bash
# Removes orphaned Tailnet devices and Tailscale Services left by a previous cluster,
# so new ones do not register as <name>-1, <name>-2, etc.
# Only touches resources tagged with one of K8S_TAGS whose name is one of the
# given hostnames (with or without the -N suffixes Tailscale adds to repeated names).
set -e

# Script base directory
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TFVARS_FILE="$DIR/apps/terraform.tfvars"
API="https://api.tailscale.com/api/v2"
K8S_TAGS='["tag:k8s-operator", "tag:k8s"]'

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
TOKEN_RESPONSE=$(curl -s -f -X POST "$API/oauth/token" \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" 2>/dev/null || true)

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.access_token // empty')

if [[ -z "$ACCESS_TOKEN" ]]; then
  echo "[Tailscale Cleanup] Could not get an API token. Skipping cleanup."
  exit 0
fi

HOSTNAMES_JSON=$(printf '%s\n' "${HOSTNAMES[@]}" | jq -R . | jq -s .)

# jq filter: tagged with one of K8S_TAGS and named after one of HOSTNAMES
MATCH='(((.tags // []) as $t | $k8s | any(. as $k | $t | index($k) != null))
  and (($name | sub("(-[0-9]+)+$"; "")) as $h | $hosts | index($h) != null))'

# delete_resource KIND NAME URL
delete_resource() {
  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE \
    -H "Authorization: Bearer $ACCESS_TOKEN" "$3" || true)
  if [[ "$status" == "200" || "$status" == "204" ]]; then
    echo "[Tailscale Cleanup] ✓ $1 $2 removed."
  else
    echo "[Tailscale Cleanup] ✗ Could not remove $1 $2 (HTTP $status)."
  fi
}

echo "[Tailscale Cleanup] Looking for devices and services: ${HOSTNAMES[*]}..."
FOUND=0

DEVICES_JSON=$(curl -s -f -H "Authorization: Bearer $ACCESS_TOKEN" "$API/tailnet/-/devices" 2>/dev/null || true)
if [[ -n "$DEVICES_JSON" ]]; then
  while IFS=$'\t' read -r id name; do
    [[ -z "$id" ]] && continue
    FOUND=1
    delete_resource "Device" "$name" "$API/device/$id"
  done < <(echo "$DEVICES_JSON" | jq -r --argjson hosts "$HOSTNAMES_JSON" --argjson k8s "$K8S_TAGS" \
    ".devices[] | (.name | split(\".\")[0]) as \$name | select($MATCH) | [.id, .name] | @tsv")
else
  echo "[Tailscale Cleanup] Could not list devices."
fi

SERVICES_JSON=$(curl -s -f -H "Authorization: Bearer $ACCESS_TOKEN" "$API/tailnet/-/vip-services" 2>/dev/null || true)
if [[ -n "$SERVICES_JSON" ]]; then
  while IFS= read -r name; do
    [[ -z "$name" ]] && continue
    FOUND=1
    delete_resource "Service" "$name" "$API/tailnet/-/vip-services/$name"
  done < <(echo "$SERVICES_JSON" | jq -r --argjson hosts "$HOSTNAMES_JSON" --argjson k8s "$K8S_TAGS" \
    ".vipServices[]? | (.name | sub(\"^svc:\"; \"\")) as \$name | select($MATCH) | .name")
else
  echo "[Tailscale Cleanup] Could not list services."
fi

if [[ "$FOUND" == "0" ]]; then
  echo "[Tailscale Cleanup] No orphaned devices or services to remove."
else
  echo "[Tailscale Cleanup] Cleanup completed."
fi
