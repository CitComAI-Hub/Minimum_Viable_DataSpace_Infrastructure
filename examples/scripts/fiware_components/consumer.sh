#!/bin/bash

POST_user_access_token() {
    if [ "$#" -lt 5 ]; then
      echo "Usage: POST_user_access_token CLUSTER_LOCAL_IP KEYCLOAK_USER_PATH KEYCLOAK_DNS KEYCLOAK_USER_NAME KEYCLOAK_USER_PASSWORD [jq_filter]"
      return 1
    fi

    local CLUSTER_LOCAL_IP="$1"
    local KEYCLOAK_USER_PATH="$2"
    local KEYCLOAK_DNS="$3"
    local KEYCLOAK_USER_NAME="$4"
    local KEYCLOAK_USER_PASSWORD="$5"
    local jq_filter="$6"

    local response
    response=$(curl -s -X POST "http://${CLUSTER_LOCAL_IP}/${KEYCLOAK_USER_PATH}/openid-connect/token" \
        --header "Host: ${KEYCLOAK_DNS}" \
        --header 'Accept: */*' \
        --header 'Content-Type: application/x-www-form-urlencoded' \
        --data grant_type=password \
        --data client_id=admin-cli \
        --data username="${KEYCLOAK_USER_NAME}" \
        --data password="${KEYCLOAK_USER_PASSWORD}")

    if [ -n "$jq_filter" ]; then
        echo "$response" | jq "$jq_filter" -r
    else
        echo "$response"
    fi
}

GET_credential_issuer_info() {
    if [ "$#" -lt 2 ]; then
        echo "Usage: GET_credential_issuer_info CLUSTER_LOCAL_IP KEYCLOAK_DNS"
        return 1
    fi

    local CLUSTER_LOCAL_IP="$1"
    local KEYCLOAK_DNS="$2"

    local response
    response=$(curl -s -X GET "http://${CLUSTER_LOCAL_IP}/realms/test-realm/.well-known/openid-credential-issuer" \
        --header "Host: ${KEYCLOAK_DNS}")
    echo "$response" | jq
}

GET_credential_offer_uri() {
    if [ "$#" -lt 4 ]; then
        echo "Usage: GET_credential_offer_uri CLUSTER_LOCAL_IP KEYCLOAK_USER_PATH KEYCLOAK_DNS ACCESS_TOKEN [jq_filter]"
        return 1
    fi

    local CLUSTER_LOCAL_IP="$1"
    local KEYCLOAK_USER_PATH="$2"
    local KEYCLOAK_DNS="$3"
    local ACCESS_TOKEN="$4"
    local jq_filter="$5"

    local response
    response=$(curl -s -X GET "http://${CLUSTER_LOCAL_IP}/${KEYCLOAK_USER_PATH}/oid4vc/credential-offer-uri?credential_configuration_id=user-credential" \
        --header "Host: ${KEYCLOAK_DNS}" \
        --header "Authorization: Bearer ${ACCESS_TOKEN}")

    if [ -n "$jq_filter" ]; then
        echo "$response" | jq "$jq_filter" -r
    else
        echo "$response"
    fi
}

GET_pre_authorized_code() {
    if [ "$#" -lt 4 ]; then
        echo "Usage: GET_pre_authorized_code OFFER_URI CLUSTER_LOCAL_IP KEYCLOAK_DNS ACCESS_TOKEN [jq_filter]"
        return 1
    fi

    local OFFER_URI="$1"
    local CLUSTER_LOCAL_IP="$2"
    local KEYCLOAK_DNS="$3"
    local ACCESS_TOKEN="$4"
    local jq_filter="$5"

    local response
    response=$(curl -s -X GET "${OFFER_URI}" \
        --resolve "${KEYCLOAK_DNS}:80:${CLUSTER_LOCAL_IP}" \
        --header "Authorization: Bearer ${ACCESS_TOKEN}")

    if [ -n "$jq_filter" ]; then
        echo "$response" | jq "$jq_filter" -r
    else
        echo "$response" | jq
    fi
}

POST_credential_access_token() {
    if [ "$#" -lt 4 ]; then
        echo "Usage: POST_credential_access_token CLUSTER_LOCAL_IP KEYCLOAK_USER_PATH KEYCLOAK_DNS PRE_AUTHORIZED_CODE [jq_filter]"
        return 1
    fi

    local CLUSTER_LOCAL_IP="$1"
    local KEYCLOAK_USER_PATH="$2"
    local KEYCLOAK_DNS="$3"
    local PRE_AUTHORIZED_CODE="$4"
    local jq_filter="$5"

    local response
    response=$(curl -s -X POST "http://${CLUSTER_LOCAL_IP}/${KEYCLOAK_USER_PATH}/openid-connect/token" \
        --header "Host: ${KEYCLOAK_DNS}" \
        --header 'Accept: */*' \
        --header 'Content-Type: application/x-www-form-urlencoded' \
        --data grant_type=urn:ietf:params:oauth:grant-type:pre-authorized_code \
        --data pre-authorized_code=${PRE_AUTHORIZED_CODE})

    if [ -n "$jq_filter" ]; then
        echo "$response" | jq "$jq_filter" -r
    else
        echo "$response" | jq
    fi
}

POST_verifiable_credential() {
    if [ "$#" -lt 4 ]; then
        echo "Usage: POST_verifiable_credential CLUSTER_LOCAL_IP KEYCLOAK_USER_PATH KEYCLOAK_DNS CREDENTIAL_ACCESS_TOKEN [jq_filter]"
        return 1
    fi

    local CLUSTER_LOCAL_IP="$1"
    local KEYCLOAK_USER_PATH="$2"
    local KEYCLOAK_DNS="$3"
    local CREDENTIAL_ACCESS_TOKEN="$4"
    local jq_filter="$5"

    local response
    response=$(curl -s -X POST "http://${CLUSTER_LOCAL_IP}/${KEYCLOAK_USER_PATH}/oid4vc/credential" \
        --header "Host: ${KEYCLOAK_DNS}" \
        --header 'Accept: */*' \
        --header 'Content-Type: application/json' \
        --header "Authorization: Bearer ${CREDENTIAL_ACCESS_TOKEN}" \
        --data '{"credential_identifier":"user-credential", "format":"jwt_vc"}')

    if [ -n "$jq_filter" ]; then
        echo "$response" | jq "$jq_filter" -r
    else
        echo "$response" | jq
    fi
}