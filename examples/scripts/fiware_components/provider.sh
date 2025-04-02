GET_token_endpoint() {
    if [ "$#" -lt 2 ]; then
        echo "Usage: GET_token_endpoint CLUSTER_LOCAL_IP GATEWAY_DNS [jq_filter]"
        return 1
    fi

    local CLUSTER_LOCAL_IP="$1"
    local GATEWAY_DNS="$2"
    local jq_filter="$3"

    local response
    response=$(curl -s -X GET "http://${CLUSTER_LOCAL_IP}/.well-known/openid-configuration" \
        --header "Host: ${GATEWAY_DNS}")

    if [ -n "$jq_filter" ]; then
        echo "$response" | jq "$jq_filter" -r
    else
        echo "$response" | jq
    fi
}