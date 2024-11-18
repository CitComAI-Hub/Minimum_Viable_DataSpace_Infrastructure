#!/bin/bash

unset ACCESS_TOKEN; unset OFFER_URI; unset PRE_AUTHORIZED_CODE; \
unset CREDENTIAL_ACCESS_TOKEN; unset VERIFIABLE_CREDENTIAL; unset HOLDER_DID; \
unset VERIFIABLE_PRESENTATION; unset JWT_HEADER; unset PAYLOAD; unset SIGNATURE; unset JWT; \
unset VP_TOKEN; unset DATA_SERVICE_ACCESS_TOKEN;

export ACCESS_TOKEN=$(curl -s -X POST "http://keycloak.consumer-a.local/realms/test-realm/protocol/openid-connect/token" \
  --header 'Accept: */*' \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data grant_type=password \
  --data client_id=admin-cli \
  --data username=test-user \
  --data password=test | jq '.access_token' -r)
echo -e "\n>> Access token: $ACCESS_TOKEN"

export OFFER_URI=$(curl -s -X GET "http://keycloak.consumer-a.local/realms/test-realm/protocol/oid4vc/credential-offer-uri?credential_configuration_id=user-credential" \
  --header "Authorization: Bearer ${ACCESS_TOKEN}" | jq '"\(.issuer)\(.nonce)"' -r)
echo -e "\n>> Offer URI: $OFFER_URI"

export PRE_AUTHORIZED_CODE=$(curl -s -X GET ${OFFER_URI} \
  --header "Authorization: Bearer ${ACCESS_TOKEN}" | jq '.grants."urn:ietf:params:oauth:grant-type:pre-authorized_code"."pre-authorized_code"' -r)
echo -e "\n>> Pre-authorized code: $PRE_AUTHORIZED_CODE"

export CREDENTIAL_ACCESS_TOKEN=$(curl -s -X POST "http://keycloak.consumer-a.local/realms/test-realm/protocol/openid-connect/token" \
  --header 'Accept: */*' \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data grant_type=urn:ietf:params:oauth:grant-type:pre-authorized_code \
  --data code=${PRE_AUTHORIZED_CODE} | jq '.access_token' -r)
echo -e "\n>> Credential access token: $CREDENTIAL"

export VERIFIABLE_CREDENTIAL=$(curl -s -X POST "http://keycloak.consumer-a.local/realms/test-realm/protocol/oid4vc/credential" \
  --header 'Accept: */*' \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer ${CREDENTIAL_ACCESS_TOKEN}" \
  --data '{"credential_identifier":"user-credential", "format":"jwt_vc"}' | jq '.credential' -r)
echo -e "\n>> Verifiable credential: $VERIFIABLE_CREDENTIAL"

export TOKEN_ENDPOINT=$(curl -s -X GET 'http:/apisix-proxy.provider-a.local/.well-known/openid-configuration' | jq -r '.token_endpoint')
echo -e "\n>> Token endpoint $TOKEN_ENDPOINT"

export HOLDER_DID=$(cat did.json | jq '.id' -r)
echo -e "\n>> Holder DID: $HOLDER_DID"

export VERIFIABLE_PRESENTATION="{
  \"@context\": [\"https://www.w3.org/2018/credentials/v1\"],
  \"type\": [\"VerifiablePresentation\"],
  \"verifiableCredential\": [
      \"${VERIFIABLE_CREDENTIAL}\"
  ],
  \"holder\": \"${HOLDER_DID}\"
}"
echo -e "\n>> Verifiable presentation: $VERIFIABLE_PRESENTATION"

export JWT_HEADER=$(echo -n "{\"alg\":\"ES256\", \"typ\":\"JWT\", \"kid\":\"${HOLDER_DID}\"}"| base64 -w0 | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//)
echo -e "\n>> JWT header: $JWT_HEADER"

export PAYLOAD=$(echo -n "{\"iss\": \"${HOLDER_DID}\", \"sub\": \"${HOLDER_DID}\", \"vp\": ${VERIFIABLE_PRESENTATION}}" | base64 -w0 | sed s/\+/-/g |sed 's/\//_/g' |  sed -E s/=+$//)
echo -e "\n>> Payload: $PAYLOAD"

export SIGNATURE=$(echo -n "${JWT_HEADER}.${PAYLOAD}" | openssl dgst -sha256 -binary -sign private-key.pem | base64 -w0 | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//)
echo -e "\n >> Signature: $SIGNATURE"

export JWT="${JWT_HEADER}.${PAYLOAD}.${SIGNATURE}"
echo -e "\n>> JWT: $JWT"

export VP_TOKEN=$(echo -n ${JWT} | base64 -w0 | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//)
echo -e "\n>> VP token: $VP_TOKEN"

export DATA_SERVICE_ACCESS_TOKEN=$(curl -s -X POST $TOKEN_ENDPOINT \
    --header 'Accept: */*' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data grant_type=vp_token \
    --data vp_token=${VP_TOKEN} \
    --data scope=default | jq '.access_token' -r )
echo -e "\n>> Data service access token: $DATA_SERVICE_ACCESS_TOKEN"
