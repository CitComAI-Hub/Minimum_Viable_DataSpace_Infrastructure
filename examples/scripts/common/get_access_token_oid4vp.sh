#!/bin/bash

token_endpoint=$(curl -s -X GET "http://$2/.well-known/openid-configuration" --header "Host: $1" | jq -r '.token_endpoint')
echo $token_endpoint
echo -e "\n"

holder_did=$(cat $5/did.json | jq '.id' -r)
# echo $holder_did

verifiable_presentation="{
  \"@context\": [\"https://www.w3.org/2018/credentials/v1\"],
  \"type\": [\"VerifiablePresentation\"],
  \"verifiableCredential\": [
      \"$3\"
  ],
  \"holder\": \"${holder_did}\"
}"
# echo $verifiable_presentation

jwt_header=$(echo -n "{\"alg\":\"ES256\", \"typ\":\"JWT\", \"kid\":\"${holder_did}\"}"| base64 -w0 | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//)
# echo $jwt_header
payload=$(echo -n "{\"iss\": \"${holder_did}\", \"sub\": \"${holder_did}\", \"vp\": ${verifiable_presentation}}" | base64 -w0 | sed s/\+/-/g |sed 's/\//_/g' |  sed -E s/=+$//)
# echo $payload
signature=$(echo -n "${jwt_header}.${payload}" | openssl dgst -sha256 -binary -sign $5/private-key.pem | base64 -w0 | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//)
# echo $signature
jwt="${jwt_header}.${payload}.${signature}"
# echo $jwt
vp_token=$(echo -n ${jwt} | base64 -w0 | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//)
echo $vp_token

# TODO: Revise error using resolve parameter
# echo $(curl -s -X POST $token_endpoint \
#   --header "Host: $1" \
#   --header 'Accept: */*' \
#   --header 'Content-Type: application/x-www-form-urlencoded' \
#   --data grant_type=vp_token \
#   --data vp_token=${vp_token} \
#   --data scope=$4 | jq '.access_token' -r )