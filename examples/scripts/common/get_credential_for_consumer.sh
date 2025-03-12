#!/bin/bash

access_token=$(curl -s -X POST "http://$2/realms/test-realm/protocol/openid-connect/token" \
  --header "Host: $1" \
  --header 'Accept: */*' \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data grant_type=password \
  --data client_id=admin-cli \
  --data username=test-user \
  --data password=test | jq '.access_token' -r)
# echo $access_token

offer_uri=$(curl -s -X GET "http://$2/realms/test-realm/protocol/oid4vc/credential-offer-uri?credential_configuration_id=$3" \
  --header "Host: $1" \
  --header "Authorization: Bearer ${access_token}" | jq '"\(.issuer)\(.nonce)"' -r)
# echo $offer_uri

export pre_authorized_code=$(curl -s -X GET ${offer_uri} \
  --resolve "$1:80:$2" \
  --header "Authorization: Bearer ${access_token}" | jq '.grants."urn:ietf:params:oauth:grant-type:pre-authorized_code"."pre-authorized_code"' -r)
# echo $pre_authorized_code

credential_access_token=$(curl -s -X POST "http://$2/realms/test-realm/protocol/openid-connect/token" \
  --header "Host: $1" \
  --header 'Accept: */*' \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data grant_type=urn:ietf:params:oauth:grant-type:pre-authorized_code \
  --data pre-authorized_code=${pre_authorized_code} | jq '.access_token' -r)
# echo $credential_access_token

curl -s -X POST "http://$2/realms/test-realm/protocol/oid4vc/credential" \
  --header "Host: $1" \
  --header 'Accept: */*' \
  --header 'Content-Type: application/json' \
  --header "Authorization: Bearer ${credential_access_token}" \
  --data "{\"credential_identifier\":\"$3\", \"format\":\"jwt_vc\"}" | jq '.credential' -r