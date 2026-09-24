#!/usr/bin/env bash
set -e

# Directorio base del script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TFVARS_FILE="$DIR/apps/terraform.tfvars"

CLIENT_ID="${TF_VAR_tailscale_oauth_client_id:-$TAILSCALE_CLIENT_ID}"
CLIENT_SECRET="${TF_VAR_tailscale_oauth_client_secret:-$TAILSCALE_CLIENT_SECRET}"

# Si no están en variables de entorno, extraer de apps/terraform.tfvars
if [[ -z "$CLIENT_ID" || -z "$CLIENT_SECRET" ]] && [[ -f "$TFVARS_FILE" ]]; then
  CLIENT_ID=$(grep -E '^\s*tailscale_oauth_client_id\s*=' "$TFVARS_FILE" | head -1 | sed -E 's/.*=\s*"([^"]+)".*/\1/' || true)
  CLIENT_SECRET=$(grep -E '^\s*tailscale_oauth_client_secret\s*=' "$TFVARS_FILE" | head -1 | sed -E 's/.*=\s*"([^"]+)".*/\1/' || true)
fi

if [[ -z "$CLIENT_ID" || -z "$CLIENT_SECRET" || "$CLIENT_ID" == *"xxxxxx"* ]]; then
  echo "[Tailscale Cleanup] No se encontraron credenciales válidas en apps/terraform.tfvars. Omitiendo limpieza."
  exit 0
fi

echo "[Tailscale Cleanup] Solicitando token de autenticación a la API de Tailscale..."
TOKEN_RESPONSE=$(curl -s -f -X POST "https://api.tailscale.com/api/v2/oauth/token" \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" 2>/dev/null || true)

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.access_token // empty')

if [[ -z "$ACCESS_TOKEN" ]]; then
  echo "[Tailscale Cleanup] No se pudo obtener el token de API. Omitiendo limpieza."
  exit 0
fi

echo "[Tailscale Cleanup] Buscando dispositivos asociados a tag:k8s-operator..."
DEVICES_JSON=$(curl -s -f -H "Authorization: Bearer $ACCESS_TOKEN" "https://api.tailscale.com/api/v2/tailnet/-/devices" 2>/dev/null || true)

if [[ -z "$DEVICES_JSON" ]]; then
  echo "[Tailscale Cleanup] No se pudieron listar los dispositivos."
  exit 0
fi

# Filtra dispositivos que tengan tag:k8s-operator o cuyos nombres sean operadores/traefik del clúster
TARGET_DEVICES=$(echo "$DEVICES_JSON" | jq -c '.devices[] | select(
  (.tags != null and (.tags | index("tag:k8s-operator") != null)) or
  (.name | test("^(tailscale-operator|traefik).*"))
) | {id: .id, name: .name}')

if [[ -z "$TARGET_DEVICES" ]]; then
  echo "[Tailscale Cleanup] No se encontraron dispositivos huérfanos de k8s en Tailscale."
  exit 0
fi

while IFS= read -r dev; do
  DEV_ID=$(echo "$dev" | jq -r '.id')
  DEV_NAME=$(echo "$dev" | jq -r '.name')

  echo "[Tailscale Cleanup] Eliminando dispositivo de Tailnet: $DEV_NAME (ID: $DEV_ID)..."
  DELETE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    "https://api.tailscale.com/api/v2/device/$DEV_ID" || true)

  if [[ "$DELETE_STATUS" == "200" || "$DELETE_STATUS" == "204" ]]; then
    echo "[Tailscale Cleanup] ✓ $DEV_NAME eliminado correctamente de Tailscale."
  else
    echo "[Tailscale Cleanup] ✗ No se pudo eliminar $DEV_NAME (HTTP $DELETE_STATUS)."
  fi
done <<< "$TARGET_DEVICES"

echo "[Tailscale Cleanup] Limpieza completada."
