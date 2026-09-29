#!/bin/sh
# Vault bootstrap and reconciler. Idempotent, runs in a loop:
#   - initialises Vault on first start and stores the keys in the "vault-init" Secret
#   - unseals Vault whenever it is sealed (e.g. after a pod restart)
#   - enables KV v2 at secret/ and the Kubernetes auth method
#   - reconciles the consumers declared in ConfigMaps labelled $CONSUMER_LABEL:
#     one policy and one role per consumer, plus the secrets it needs
# The pod is Ready (READY_FILE exists) only while Vault is unsealed and configured.
# Any error exits the script so Kubernetes restarts the container and retries.
set -eu

VAULT="${VAULT_ADDR:?VAULT_ADDR is required}"
NS="${NAMESPACE:?NAMESPACE is required}"
LABEL="${CONSUMER_LABEL:?CONSUMER_LABEL is required}"
INIT_SECRET="vault-init"
READY_FILE="/tmp/ready"
# Policies and roles managed by this script; others in Vault are left untouched
PREFIX="eso-"

log() { echo "[vault-bootstrap] $*"; }

# vcurl METHOD PATH [BODY]  (uses VAULT_TOKEN when set)
vcurl() {
  _method="$1"; _path="$2"; _body="${3-}"
  if [ -n "$_body" ]; then
    curl -sSf --max-time 20 -X "$_method" \
      -H "X-Vault-Token: ${VAULT_TOKEN:-}" -H "Content-Type: application/json" \
      -d "$_body" "$VAULT$_path"
  else
    curl -sSf --max-time 20 -X "$_method" \
      -H "X-Vault-Token: ${VAULT_TOKEN:-}" "$VAULT$_path"
  fi
}

get_init_json() {
  kubectl -n "$NS" get secret "$INIT_SECRET" -o jsonpath='{.data.init_json}' | base64 -d
}

do_init() {
  log "Vault not initialised: initialising"
  out=$(curl -sSf --max-time 30 -X PUT -H "Content-Type: application/json" \
    -d '{"secret_shares":1,"secret_threshold":1}' "$VAULT/v1/sys/init")
  n=0
  until kubectl -n "$NS" create secret generic "$INIT_SECRET" \
      --from-literal=init_json="$out" --dry-run=client -o yaml | kubectl apply -f - >/dev/null; do
    n=$((n + 1))
    if [ "$n" -ge 30 ]; then log "ERROR: could not store the $INIT_SECRET secret"; exit 1; fi
    sleep 2
  done
  log "Init keys stored in the $INIT_SECRET secret"
}

do_unseal() {
  init_json=$(get_init_json) || { log "Secret $INIT_SECRET not found"; return 1; }
  # accepts both the API format (keys_base64) and the CLI format (unseal_keys_b64)
  for key in $(echo "$init_json" | jq -r '(.keys_base64 // .unseal_keys_b64)[]'); do
    res=$(curl -sSf --max-time 20 -X PUT -H "Content-Type: application/json" \
      -d "{\"key\":\"$key\"}" "$VAULT/v1/sys/unseal") || return 1
    if [ "$(echo "$res" | jq -r .sealed)" = "false" ]; then
      log "Vault unsealed"
      return 0
    fi
  done
  return 1
}

configure_base() {
  # KV v2 engine at secret/
  if ! vcurl GET /v1/sys/mounts | jq -e '.data["secret/"]' >/dev/null 2>&1; then
    log "Enabling KV v2 at secret/"
    vcurl POST /v1/sys/mounts/secret '{"type":"kv","options":{"version":"2"}}' >/dev/null
  fi

  # Kubernetes auth (Vault validates tokens with its own ServiceAccount)
  if ! vcurl GET /v1/sys/auth | jq -e '.data["kubernetes/"]' >/dev/null 2>&1; then
    log "Enabling kubernetes auth"
    vcurl POST /v1/sys/auth/kubernetes '{"type":"kubernetes"}' >/dev/null
  fi
  vcurl POST /v1/auth/kubernetes/config \
    '{"kubernetes_host":"https://kubernetes.default.svc:443"}' >/dev/null
}

# reconcile_consumer CONSUMER_JSON
reconcile_consumer() {
  c="$1"
  name=$(echo "$c" | jq -r .name)
  ns=$(echo "$c" | jq -r .namespace)
  sa=$(echo "$c" | jq -r .service_account)
  role="$PREFIX$name"

  # Read-only policy over the consumer's own paths
  policy=$(echo "$c" | jq -r \
    '[.secrets[].vault_path] | unique[] | "path \"secret/data/\(.)\" {\n  capabilities = [\"read\"]\n}"')
  vcurl PUT "/v1/sys/policies/acl/$role" "$(jq -n --arg p "$policy" '{policy:$p}')" >/dev/null

  vcurl PUT "/v1/auth/kubernetes/role/$role" "$(jq -n --arg sa "$sa" --arg ns "$ns" --arg p "$role" \
    '{bound_service_account_names:[$sa],bound_service_account_namespaces:[$ns],policies:[$p],ttl:"1h"}')" >/dev/null

  echo "$c" | jq -c '.secrets[]' | while read -r spec; do
    path=$(echo "$spec" | jq -r .vault_path)
    static=$(echo "$spec" | jq -c '.static // {}')

    existing=$(vcurl GET "/v1/secret/data/$path" 2>/dev/null | jq -S -c '.data.data // {}' || true)
    [ -n "$existing" ] || existing='{}'

    # static values are always applied; generated ones only when missing (no rotation)
    data=$(echo "$existing" | jq -S -c --argjson s "$static" '. * $s')
    for f in $(echo "$spec" | jq -r '.generated_fields[]?'); do
      if ! echo "$data" | jq -e --arg f "$f" 'has($f)' >/dev/null; then
        val=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32)
        data=$(echo "$data" | jq -S -c --arg f "$f" --arg v "$val" '. + {($f): $v}')
      fi
    done

    if [ "$data" != "$existing" ]; then
      vcurl POST "/v1/secret/data/$path" "$(jq -n -c --argjson d "$data" '{data:$d}')" >/dev/null
      log "Secret secret/$path updated"
    fi
  done
  log "Consumer $name ($ns): policy, role and secrets applied"
}

# Removes roles and policies of consumers that no longer exist. KV data is kept
# on purpose, so removing a consumer by mistake never loses secrets.
prune_consumers() {
  wanted=$(echo "$1" | jq -c --arg p "$PREFIX" '[.[].name | $p + .]')
  roles=$(vcurl LIST /v1/auth/kubernetes/role 2>/dev/null | jq -r '.data.keys[]?' || true)
  for role in $roles; do
    case "$role" in "$PREFIX"*) ;; *) continue ;; esac
    if ! echo "$wanted" | jq -e --arg r "$role" 'index($r) != null' >/dev/null; then
      vcurl DELETE "/v1/auth/kubernetes/role/$role" >/dev/null
      vcurl DELETE "/v1/sys/policies/acl/$role" >/dev/null
      log "Consumer ${role#"$PREFIX"} removed: role and policy deleted"
    fi
  done
}

applied=""
while true; do
  if ! st=$(curl -sSf --max-time 10 "$VAULT/v1/sys/seal-status" 2>/dev/null); then
    rm -f "$READY_FILE"
    log "Vault not responding yet, retrying"
    sleep 5
    continue
  fi

  if [ "$(echo "$st" | jq -r .initialized)" = "false" ]; then
    rm -f "$READY_FILE"
    do_init
    continue
  fi

  if [ "$(echo "$st" | jq -r .sealed)" = "true" ]; then
    rm -f "$READY_FILE"
    applied=""
    do_unseal || log "Could not unseal, retrying"
    sleep 3
    continue
  fi

  consumers=$(kubectl -n "$NS" get configmap -l "$LABEL" -o json \
    | jq -S -c '[.items[].data["consumer.json"] | fromjson] | sort_by(.name)')

  if [ "$consumers" != "$applied" ]; then
    VAULT_TOKEN=$(get_init_json | jq -r .root_token)
    configure_base
    echo "$consumers" | jq -c '.[]' | while read -r c; do
      reconcile_consumer "$c"
    done
    prune_consumers "$consumers"
    VAULT_TOKEN=""
    applied="$consumers"
    log "Configuration applied ($(echo "$consumers" | jq length) consumers)"
  fi

  touch "$READY_FILE"
  sleep 10
done
