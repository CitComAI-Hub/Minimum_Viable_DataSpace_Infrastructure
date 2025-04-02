#!/bin/bash

GET_issuer_list() {
    # $1: CLUSTER_LOCAL_IP
    # $2: TIR_OPERATOR_DNS
    local result
    result=$(curl -s -X GET "http://$1/v4/issuers" -H "Host: $2" | jq)
    echo "$result"
}

POST_register_issuer() {
    # $1: CLUSTER_LOCAL_IP
    # $2: TIL_OPERATOR_DNS
    # $3: JSON_DATA
    local result
    result=$(curl -s -X POST "http://$1/issuer" \
        --header "Host: $2" \
        --header "Content-Type: application/json" \
        --data "$3")
    echo "$result"
}