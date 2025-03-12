#!/bin/bash

certs_path="../../my_certs"

CLUSTER_LOCAL_IP="172.18.255.200"

################
# Trust Anchor #
################
TIR_OPERATOR_DNS="tir.ds-operator.local" # list issuers
TIL_OPERATOR_DNS="til.ds-operator.local" # register issuer

################
# Consumer     #
################
KEYCLOAK_DNS="keycloak.consumer-a.local"
KEYCLOAK_USER_PATH="realms/test-realm/protocol"
KEYCLOAK_USER_NAME="test-user"
KEYCLOAK_USER_PASSWORD="test"
#did-consumer
DID_CONSUMER_DNS="did-helper.consumer-a.local"

################
# Provider     #
################
GATEWAY_DNS="apisix-proxy.provider-a.local"
#PAP
PAP_PROVIDER_DNS="pap-odrl.provider-a.local"
#Data Service
SCORPIO_PROVIDER_DNS="scorpio-broker.provider-a.local"
#tm-forum-api
TM_FORUM_API_PROVIDER_DNS="tm-forum-api.provider-a.local"
#vc.verifier
VC_VERIFIER_PROVIDER_DNS="vc-verifier.provider-a.local"

# Función para formatear un string en negrita y letras azules
formatear_negrita_azul() {
    local texto="$1"
    # Código de escape ANSI para negrita y azul
    local negrita_azul="\e[1;34m"
    local reset="\e[0m"
    # Imprimir el texto formateado
    echo -e "${negrita_azul}${texto}${reset}"
}

# Para eliminar las variables de entorno si existen
unset ACCESS_TOKEN
unset OFFER_URI
unset PRE_AUTHORIZED_CODE
unset CREDENTIAL_ACCESS_TOKEN
unset VERIFIABLE_CREDENTIAL
unset HOLDER_DID
unset VERIFIABLE_PRESENTATION
unset JWT_HEADER
unset PAYLOAD
unset SIGNATURE
unset JWT
unset VP_TOKEN
unset DATA_SERVICE_ACCESS_TOKEN

################################################################################
# TRUST ANCHOR                                                                 #
################################################################################
# Trust Anchor API: https://github.com/FIWARE/trusted-issuers-list/blob/main/api/trusted-issuers-list.yaml

# # Register new issuer:
# echo -e "$(formatear_negrita_azul "[Trust Anchor] - Register new issuer. ") \
#     $(curl -s -X POST http://${CLUSTER_LOCAL_IP}/issuer \
#         --header "Host: ${TIL_OPERATOR_DNS}" \
#         --header 'Content-Type: application/json' \
#         --data '{
#         "did": "did:key:myKey79846",
#         "credentials": []}' \
#     )\n"

# Get a list of the issuers:
echo -e "$(formatear_negrita_azul "[Trust Anchor] - List of issuers: ") \
    $(curl -s -X GET http://${CLUSTER_LOCAL_IP}/v4/issuers -H "Host: ${TIR_OPERATOR_DNS}" | jq)\n"


################################################################################
# CONSUMER                                                                     #
################################################################################

# Get the credential via http requests:
export ACCESS_TOKEN=$(curl -s -X POST "http://${CLUSTER_LOCAL_IP}/${KEYCLOAK_USER_PATH}/openid-connect/token" \
    --header "Host: ${KEYCLOAK_DNS}" \
    --header 'Accept: */*' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data grant_type=password \
    --data client_id=admin-cli \
    --data username=${KEYCLOAK_USER_NAME} \
    --data password=${KEYCLOAK_USER_PASSWORD} | jq '.access_token' -r)
echo -e "$(formatear_negrita_azul "[CONSUMER] - User access TOKEN (Keycloak):") $ACCESS_TOKEN\n"

# Get the credentials issuer information (Optional):
echo -e "$(formatear_negrita_azul "[CONSUMER] - Credentials issuer information:") \
    $(curl -s -X GET http://${CLUSTER_LOCAL_IP}/realms/test-realm/.well-known/openid-credential-issuer --header "Host: ${KEYCLOAK_DNS}" | jq)\n"

# #! The offer and the pre-authorized code expire within 30s for security reasons. Be fast.

# Get a credential offer uri(for the `user-credential), using the retrieved AccessToken:
export OFFER_URI=$(curl -s -X GET "http://${CLUSTER_LOCAL_IP}/${KEYCLOAK_USER_PATH}/oid4vc/credential-offer-uri?credential_configuration_id=user-credential" \
    --header "Host: ${KEYCLOAK_DNS}" \
    --header "Authorization: Bearer ${ACCESS_TOKEN}" | jq '"\(.issuer)\(.nonce)"' -r)
echo -e "$(formatear_negrita_azul "[CONSUMER] - Offer URI for \e[3muser-credential\e[0m") $(formatear_negrita_azul "(expiration time 30s):") $OFFER_URI"

# Use the offer uri to retrieve the actual offer:
export PRE_AUTHORIZED_CODE=$(curl -s -X GET ${OFFER_URI} \
    --resolve "${KEYCLOAK_DNS}:80:${CLUSTER_LOCAL_IP}" \
    --header "Authorization: Bearer ${ACCESS_TOKEN}" | jq '.grants."urn:ietf:params:oauth:grant-type:pre-authorized_code"."pre-authorized_code"' -r)
echo -e "$(formatear_negrita_azul "[CONSUMER] - Pre authorized code (expiration time 30s):") $PRE_AUTHORIZED_CODE"

# Exchange the pre-authorized code from the offer with an AccessToken at the authorization server:
export CREDENTIAL_ACCESS_TOKEN=$(curl -s -X POST "http://${CLUSTER_LOCAL_IP}/${KEYCLOAK_USER_PATH}/openid-connect/token" \
    --header "Host: ${KEYCLOAK_DNS}" \
    --header 'Accept: */*' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data grant_type=urn:ietf:params:oauth:grant-type:pre-authorized_code \
    --data pre-authorized_code=${PRE_AUTHORIZED_CODE} | jq '.access_token' -r);
echo -e "$(formatear_negrita_azul "[CONSUMER] - Credential Access Token:") $CREDENTIAL_ACCESS_TOKEN"

# Use the returned access token to get the actual credential:
export VERIFIABLE_CREDENTIAL=$(curl -s -X POST "http://${CLUSTER_LOCAL_IP}/${KEYCLOAK_USER_PATH}/oid4vc/credential" \
    --header "Host: ${KEYCLOAK_DNS}" \
    --header 'Accept: */*' \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer ${CREDENTIAL_ACCESS_TOKEN}" \
    --data '{"credential_identifier":"user-credential", "format":"jwt_vc"}' | jq '.credential' -r)
echo -e "$(formatear_negrita_azul "[CONSUMER] - Verifiable Credential (format jwt_vc):") $VERIFIABLE_CREDENTIAL\n"


## POLICIY CREATION
##
## The policy can be created at the PAP via:
curl -X 'POST' http://${CLUSTER_LOCAL_IP}/policy \
    -H "Host: ${PAP_PROVIDER_DNS}" \
    -H 'Content-Type: application/json' \
    -d  '{
            "@context": {
                "dc": "http://purl.org/dc/elements/1.1/",
                "dct": "http://purl.org/dc/terms/",
                "owl": "http://www.w3.org/2002/07/owl#",
                "odrl": "http://www.w3.org/ns/odrl/2/",
                "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
                "skos": "http://www.w3.org/2004/02/skos/core#"
            },
            "@id": "https://mp-operation.org/policy/common/type",
            "@type": "odrl:Policy",
            "odrl:permission": {
                "odrl:assigner": {
                "@id": "https://www.mp-operation.org/"
                },
                "odrl:target": {
                "@type": "odrl:AssetCollection",
                "odrl:source": "urn:asset",
                "odrl:refinement": [
                    {
                    "@type": "odrl:Constraint",
                    "odrl:leftOperand": "ngsi-ld:entityType",
                    "odrl:operator": {
                        "@id": "odrl:eq"
                    },
                    "odrl:rightOperand": "EnergyReport"
                    }
                ]
                },
                "odrl:assignee": {
                "@id": "vc:any"
                },
                "odrl:action": {
                "@id": "odrl:read"
                }
            }
            }'
echo -e "\n"
## DATA ADDITION
##
curl -X POST http://${CLUSTER_LOCAL_IP}/ngsi-ld/v1/entities \
    --header "Host: ${SCORPIO_PROVIDER_DNS}" \
    -H 'Accept: application/json' \
    -H 'Content-Type: application/json' \
    -d '{
      "id": "urn:ngsi-ld:EnergyReport:fms-1",
      "type": "EnergyReport",
      "name": {
        "type": "Property",
        "value": "Standard Server"
      },
      "consumption": {
        "type": "Property",
        "value": "94"
      }
    }'
echo -e "\n"


################################################################################
# Data access interactions                                                     #
################################################################################

# Request the oidc-information at the well-known endpoint:
export TOKEN_ENDPOINT=$(curl -s -X GET "http://${CLUSTER_LOCAL_IP}/.well-known/openid-configuration" -H "Host: ${GATEWAY_DNS}" | jq -r '.token_endpoint');
echo -e "$(formatear_negrita_azul "[PROVIDER] -  Token Endpoint:") ${TOKEN_ENDPOINT}"
curl -s -X GET "http://${CLUSTER_LOCAL_IP}/.well-known/openid-configuration" -H "Host: ${GATEWAY_DNS}" | jq && echo -e "\n"

# First, the credential needs to be encoded into a vp_token. If you want to do
# that manually, first a did and the corresponding key-material is required.
if [ ! -d "$certs_path/" ]; then
    echo -e "$(formatear_negrita_azul "[MANUAL CREDENTIAL ENCODING] - Creating certs ...")"
    mkdir -p $certs_path/
    docker run -v $(pwd)/$certs_path/:/cert quay.io/wi_stefan/did-helper:0.1.1
    sudo chmod -R o+r $certs_path/private-key.pem #https://www.youtube.com/watch?v=3fLisTubkF0 | 42:35 MIN
    echo -e "$(formatear_negrita_azul "[MANUAL CREDENTIAL ENCODING] - Certs created.")"
else
    echo -e "$(formatear_negrita_azul "[MANUAL CREDENTIAL ENCODING] - Certs already created.")"
fi
# - Get the did from the created key-material:
export HOLDER_DID=$(cat $certs_path/did.json | jq '.id' -r)
echo -e "$(formatear_negrita_azul "[MANUAL CREDENTIAL ENCODING] - DID is:") $HOLDER_DID"
export VERIFIABLE_PRESENTATION="{
    \"@context\": [\"https://www.w3.org/2018/credentials/v1\"],
    \"type\": [\"VerifiablePresentation\"],
    \"verifiableCredential\": [
        \"${VERIFIABLE_CREDENTIAL}\"
    ],
    \"holder\": \"${HOLDER_DID}\"
}"
echo -e "$(formatear_negrita_azul "[MANUAL CREDENTIAL ENCODING] - >> Verifiable Presentation:") $VERIFIABLE_PRESENTATION\n"
# - Embedded into a signed JWT
export JWT_HEADER=$(echo -n "{\"alg\":\"ES256\", \"typ\":\"JWT\", \"kid\":\"${HOLDER_DID}\"}"| base64 -w0 | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//)
echo -e "$(formatear_negrita_azul "[MANUAL CREDENTIAL ENCODING] - >> Header:") $JWT_HEADER\n"
export PAYLOAD=$(echo -n "{\"iss\": \"${HOLDER_DID}\", \"sub\": \"${HOLDER_DID}\", \"vp\": ${VERIFIABLE_PRESENTATION}}" | base64 -w0 | sed s/\+/-/g |sed 's/\//_/g' |  sed -E s/=+$//)
echo -e "$(formatear_negrita_azul "[MANUAL CREDENTIAL ENCODING] - >> Payload:") $PAYLOAD\n"
export SIGNATURE=$(echo -n "${JWT_HEADER}.${PAYLOAD}" | openssl dgst -sha256 -binary -sign $certs_path/private-key.pem | base64 -w0 | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//)
echo -e "$(formatear_negrita_azul "[MANUAL CREDENTIAL ENCODING] - >> Signature:") $SIGNATURE\n"
export JWT="${JWT_HEADER}.${PAYLOAD}.${SIGNATURE}"
echo -e "$(formatear_negrita_azul "[MANUAL CREDENTIAL ENCODING] - jwt token:") $JWT"

export VP_TOKEN=$(echo -n ${JWT} | base64 -w0 | sed s/\+/-/g | sed 's/\//_/g' | sed -E s/=+$//)
echo -e "$(formatear_negrita_azul "[MANUAL CREDENTIAL ENCODING] - VP TOKEN:") $VP_TOKEN\n"


# The vp_token can then be exchanged for the access-token
export DATA_SERVICE_ACCESS_TOKEN=$(curl -s -X POST ${TOKEN_ENDPOINT} \
    --resolve "${VC_VERIFIER_PROVIDER_DNS}:80:${CLUSTER_LOCAL_IP}" \
    --header 'Accept: */*' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data grant_type=vp_token \
    --data vp_token=${VP_TOKEN} \
    --data scope=default | jq '.access_token' -r )
echo -e "$(formatear_negrita_azul "[DATA ACCESS] - Data Service Access Token:") $DATA_SERVICE_ACCESS_TOKEN\n"

# Try data access
curl -X GET "http://${CLUSTER_LOCAL_IP}/ngsi-ld/v1/entities/urn:ngsi-ld:EnergyReport:fms-1" \
    --header "Host: ${GATEWAY_DNS}" \
    --header 'Accept: application/json' \
    --header "Authorization: Bearer ${DATA_SERVICE_ACCESS_TOKEN}"

read -p "Press enter to continue"

################################################################################
################################################################################
################################################################################

echo "========================================================================="

# Allow every authenticated participant to read offerings
curl -X 'POST' http://${CLUSTER_LOCAL_IP}/policy \
    --header "Host: ${PAP_PROVIDER_DNS}" \
    -H 'Content-Type: application/json' \
    -d  '{
          "@context": {
            "dc": "http://purl.org/dc/elements/1.1/",
            "dct": "http://purl.org/dc/terms/",
            "owl": "http://www.w3.org/2002/07/owl#",
            "odrl": "http://www.w3.org/ns/odrl/2/",
            "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
            "skos": "http://www.w3.org/2004/02/skos/core#"
          },
          "@id": "https://mp-operation.org/policy/common/type",
          "@type": "odrl:Policy",
          "odrl:permission": {
            "odrl:assigner": {
              "@id": "https://www.mp-operation.org/"
            },
            "odrl:target": {
              "@type": "odrl:AssetCollection",
              "odrl:source": "urn:asset",
              "odrl:refinement": [
                {
                  "@type": "odrl:Constraint",
                  "odrl:leftOperand": "tmf:resource",
                  "odrl:operator": {
                    "@id": "odrl:eq"
                  },
                  "odrl:rightOperand": "productOffering"
                }
              ]
            },
            "odrl:assignee": {
              "@id": "vc:any"
            },
            "odrl:action": {
              "@id": "odrl:read"
            }
          }
        }'

# Allow every authenticated participant to register as customer at M&P Operations
curl -X 'POST' http://${CLUSTER_LOCAL_IP}/policy \
    --header "Host: ${PAP_PROVIDER_DNS}" \
    -H 'Content-Type: application/json' \
    -d  '{
          "@context": {
            "dc": "http://purl.org/dc/elements/1.1/",
            "dct": "http://purl.org/dc/terms/",
            "owl": "http://www.w3.org/2002/07/owl#",
            "odrl": "http://www.w3.org/ns/odrl/2/",
            "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
            "skos": "http://www.w3.org/2004/02/skos/core#"
          },
          "@id": "https://mp-operation.org/policy/common/type",
          "@type": "odrl:Policy",
          "odrl:permission": {
            "odrl:assigner": {
              "@id": "https://www.mp-operation.org/"
            },
            "odrl:target": {
              "@type": "odrl:AssetCollection",
              "odrl:source": "urn:asset",
              "odrl:refinement": [
                {
                  "@type": "odrl:Constraint",
                  "odrl:leftOperand": "tmf:resource",
                  "odrl:operator": {
                    "@id": "odrl:eq"
                  },
                  "odrl:rightOperand": "organization"
                }
              ]
            },
            "odrl:assignee": {
              "@id": "vc:any"
            },
            "odrl:action": {
              "@id": "tmf:create"
            }
          }
        }'
# Allow product orders
curl -X 'POST' http://${CLUSTER_LOCAL_IP}/policy \
    --header "Host: ${PAP_PROVIDER_DNS}" \
    -H 'Content-Type: application/json' \
    -d  '{
          "@context": {
            "dc": "http://purl.org/dc/elements/1.1/",
            "dct": "http://purl.org/dc/terms/",
            "owl": "http://www.w3.org/2002/07/owl#",
            "odrl": "http://www.w3.org/ns/odrl/2/",
            "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
            "skos": "http://www.w3.org/2004/02/skos/core#"
          },
          "@id": "https://mp-operation.org/policy/common/type",
          "@type": "odrl:Policy",
          "odrl:permission": {
            "odrl:assigner": {
              "@id": "https://www.mp-operation.org/"
            },
            "odrl:target": {
              "@type": "odrl:AssetCollection",
              "odrl:source": "urn:asset",
              "odrl:refinement": [
                {
                  "@type": "odrl:Constraint",
                  "odrl:leftOperand": "tmf:resource",
                  "odrl:operator": {
                    "@id": "odrl:eq"
                  },
                  "odrl:rightOperand": "productOrder"
                }
              ]
            },
            "odrl:assignee": {
              "@id": "vc:any"
            },
            "odrl:action": {
              "@id": "tmf:create"
            }
          }
        }'

# Allow creation of entities of type "K8SCluster" to authenticated participants with the role "OPERATOR"
curl -X 'POST' http://${CLUSTER_LOCAL_IP}/policy \
    --header "Host: ${PAP_PROVIDER_DNS}" \
    -H 'Content-Type: application/json' \
    -d  '{
              "@context": {
                "dc": "http://purl.org/dc/elements/1.1/",
                "dct": "http://purl.org/dc/terms/",
                "owl": "http://www.w3.org/2002/07/owl#",
                "odrl": "http://www.w3.org/ns/odrl/2/",
                "rdfs": "http://www.w3.org/2000/01/rdf-schema#",
                "skos": "http://www.w3.org/2004/02/skos/core#"
              },
              "@id": "https://mp-operation.org/policy/common/type",
              "@type": "odrl:Policy",
              "odrl:permission": {
                "odrl:assigner": {
                  "@id": "https://www.mp-operation.org/"
                },
                "odrl:target": {
                  "@type": "odrl:AssetCollection",
                  "odrl:source": "urn:asset",
                  "odrl:refinement": [
                    {
                      "@type": "odrl:Constraint",
                      "odrl:leftOperand": "ngsi-ld:entityType",
                      "odrl:operator": {
                        "@id": "odrl:eq"
                      },
                      "odrl:rightOperand": "K8SCluster"
                    }
                  ]
                },
                "odrl:assignee": {
                  "@type": "odrl:PartyCollection",
                  "odrl:source": "urn:user",
                  "odrl:refinement": {
                    "@type": "odrl:LogicalConstraint",
                    "odrl:and": [
                      {
                        "@type": "odrl:Constraint",
                        "odrl:leftOperand": {
                          "@id": "vc:role"
                        },
                        "odrl:operator": {
                          "@id": "odrl:hasPart"
                        },
                        "odrl:rightOperand": {
                          "@value": "OPERATOR",
                          "@type": "xsd:string"
                        }
                      },
                      {
                        "@type": "odrl:Constraint",
                        "odrl:leftOperand": {
                          "@id": "vc:type"
                        },
                        "odrl:operator": {
                          "@id": "odrl:hasPart"
                        },
                        "odrl:rightOperand": {
                          "@value": "OperatorCredential",
                          "@type": "xsd:string"
                        }
                      }
                    ]
                  }
                },
                "odrl:action": {
                  "@id": "odrl:use"
                }
              }
            }'

# Create the product specification
export PRODUCT_SPEC_ID=$(curl -s -X 'POST' http://${CLUSTER_LOCAL_IP}/tmf-api/productCatalogManagement/v4/productSpecification \
    --header "Host: ${TM_FORUM_API_PROVIDER_DNS}" \
     -H 'Content-Type: application/json;charset=utf-8' \
     -d '{
        "brand": "M&P Operations",
        "version": "1.0.0",
        "lifecycleStatus": "ACTIVE",
        "name": "M&P K8S"
     }' | jq '.id' -r )
echo -e "\n$(formatear_negrita_azul "[TMForum API] - PRODUCT_SPEC_ID:") $PRODUCT_SPEC_ID"

# Create a product offering, referencing the spec
export PRODUCT_OFFERING_ID=$(curl -s -X 'POST' http://${CLUSTER_LOCAL_IP}/tmf-api/productCatalogManagement/v4/productOffering \
    --header "Host: ${TM_FORUM_API_PROVIDER_DNS}" \
    -H 'Content-Type: application/json;charset=utf-8' \
    -d "{
      \"version\": \"1.0.0\",
      \"lifecycleStatus\": \"ACTIVE\",
      \"name\": \"M&P K8S Offering\",
      \"productSpecification\": {
        \"id\": \"${PRODUCT_SPEC_ID}\"
      }
    }"| jq '.id' -r )
echo -e "$(formatear_negrita_azul "[TMForum API] - PRODUCT_OFFERING_ID:") $PRODUCT_OFFERING_ID\n"

########################################
# Credentials issuance at the consumer #
########################################
export USER_CREDENTIAL=$(./common/get_credential_for_consumer.sh ${KEYCLOAK_DNS} ${CLUSTER_LOCAL_IP} user-credential);
echo -e "$(formatear_negrita_azul "[CONSUMER] - User credential:") $USER_CREDENTIAL\n"

export OPERATOR_CREDENTIAL=$(./common/get_credential_for_consumer.sh ${KEYCLOAK_DNS} ${CLUSTER_LOCAL_IP} operator-credential);
echo -e "$(formatear_negrita_azul "[CONSUMER] - Operator credential:") $OPERATOR_CREDENTIAL\n"

########################################
# Buy access and create cluster        #
########################################
export ACCESS_TOKEN_USER=$(./common/get_access_token_oid4vp.sh ${GATEWAY_DNS} ${CLUSTER_LOCAL_IP} $USER_CREDENTIAL default $certs_path);
echo -e "$(formatear_negrita_azul "[??] - USER ACCESS TOKEN:") $ACCESS_TOKEN_USER"

# export CLUSTER_CREATION_ANY_USER=$(curl -s -X POST http://${CLUSTER_LOCAL_IP}/ngsi-ld/v1/entities \
#     --header "Host: ${GATEWAY_DNS}" \
#     -H 'Accept: */*' \
#     -H 'Content-Type: application/json' \
#     -H "Authorization: Bearer ${ACCESS_TOKEN_USER}" \
#     -d '{
#       "id": "urn:ngsi-ld:K8SCluster:fancy-marketplace",
#       "type": "K8SCluster",
#       "name": {
#         "type": "Property",
#         "value": "Fancy Marketplace Cluster"
#       },
#       "numNodes": {
#         "type": "Property",
#         "value": "3"
#       },
#       "k8sVersion": {
#         "type": "Property",
#         "value": "1.26.0"
#       }
#     }')
# echo -e "$(formatear_negrita_azul "[PROVIDER] - Cluster creation (any user, 403 IS OK!!):\n") $CLUSTER_CREATION_ANY_USER\n"

# export ACCESS_TOKEN_OPERATOR=$(./zz-pruebas_ejemplo-Fiwre/get_access_token_oid4vp.sh http://${GATEWAY_DNS} $OPERATOR_CREDENTIAL operator $certs_path);
# echo -e "$(formatear_negrita_azul "[??] - PROVIDER ACCESS TOKEN (no token will be returned, NULL IS OK!!):") $ACCESS_TOKEN_OPERATOR\n"

# export CONSUMER_DID=$(curl -s -X GET http://${DID_CONSUMER_DNS}/did-material/did.env | cut -d'=' -f2);
# echo -e "$(formatear_negrita_azul "[CONSUMER] - Did consumer:") $CONSUMER_DID\n"

# # Register Fancy Marketplace at M&P Operations
# export ACCESS_TOKEN_USER=$(./zz-pruebas_ejemplo-Fiwre/get_access_token_oid4vp.sh http://${GATEWAY_DNS} $USER_CREDENTIAL default $certs_path);
# echo -e "$(formatear_negrita_azul "[??] - USER ACCESS TOKEN:") $ACCESS_TOKEN_USER"
# export FANCY_MARKETPLACE_ID=$(curl -s -X POST http://${TM_FORUM_API_PROVIDER_DNS}/tmf-api/party/v4/organization \
#     -H 'Accept: */*' \
#     -H 'Content-Type: application/json' \
#     -H "Authorization: Bearer ${ACCESS_TOKEN_USER}" \
#     -d "{
#       \"name\": \"Fancy Marketplace Inc.\",
#       \"partyCharacteristic\": [
#         {
#           \"name\": \"did\",
#           \"value\": \"${CONSUMER_DID}\"
#         }
#       ]
#     }" | jq '.id' -r);

# echo -e "$(formatear_negrita_azul "[PROVIDER] - FANCY_MARKETPLACE_ID:") $FANCY_MARKETPLACE_ID\n"

# export ACCESS_TOKEN_USER=$(./zz-pruebas_ejemplo-Fiwre/get_access_token_oid4vp.sh http://${GATEWAY_DNS} $USER_CREDENTIAL default $certs_path);
# echo -e "$(formatear_negrita_azul "[??] - USER ACCESS TOKEN:") $ACCESS_TOKEN_USER"
# export LIST_OFFERING=$(curl -s -X GET http://${TM_FORUM_API_PROVIDER_DNS}/tmf-api/productCatalogManagement/v4/productOffering \
#   -H "Authorization: Bearer ${ACCESS_TOKEN_USER}")
# echo -e "$(formatear_negrita_azul "[PROVIDER] - LIST_OFFERING:")\n$(echo $LIST_OFFERING | jq '.')\n"


# export ACCESS_TOKEN_USER=$(./zz-pruebas_ejemplo-Fiwre/get_access_token_oid4vp.sh http://${GATEWAY_DNS} $USER_CREDENTIAL default $certs_path);
# echo -e "$(formatear_negrita_azul "[??] - USER ACCESS TOKEN:") $ACCESS_TOKEN_USER"
# export OFFER_ID=$(curl -s -X GET http://${TM_FORUM_API_PROVIDER_DNS}/tmf-api/productCatalogManagement/v4/productOffering \
#   -H "Authorization: Bearer ${ACCESS_TOKEN_USER}" | jq '.[0].id' -r);
# echo -e "$(formatear_negrita_azul "[PROVIDER] - OFFER_ID:") $OFFER_ID\n"

# export ACCESS_TOKEN_USER=$(./zz-pruebas_ejemplo-Fiwre/get_access_token_oid4vp.sh http://${GATEWAY_DNS} $USER_CREDENTIAL default $certs_path);
# echo -e "$(formatear_negrita_azul "[??] - USER ACCESS TOKEN:") $ACCESS_TOKEN_USER"
# export ORDER_CREATION=$(curl -s -X POST http://${TM_FORUM_API_PROVIDER_DNS}/tmf-api/productOrderingManagement/v4/productOrder \
#    -H 'Accept: */*' \
#    -H 'Content-Type: application/json' \
#    -H "Authorization: Bearer ${ACCESS_TOKEN_USER}" \
#    -d "{
#        \"productOrderItem\": [
#          {
#            \"id\": \"random-order-id\",
#            \"action\": \"add\",
#            \"productOffering\": {
#              \"id\" :  \"${OFFER_ID}\"
#            }
#          }
#        ],
#        \"relatedParty\": [
#          {
#            \"id\": \"${FANCY_MARKETPLACE_ID}\"
#          }
#        ]}" | jq '.')
# echo -e "$(formatear_negrita_azul "[TMFORUM] - ORDER_CREATION:")\n$ORDER_CREATION\n"

# export ACCESS_TOKEN_OPERATOR=$(./zz-pruebas_ejemplo-Fiwre/get_access_token_oid4vp.sh http://${GATEWAY_DNS} $OPERATOR_CREDENTIAL operator $certs_path);
# echo -e "$(formatear_negrita_azul "[??] - OPERATOR ACCESS TOKEN:") $ACCESS_TOKEN_OPERATOR\n"
# curl -X POST http://${GATEWAY_DNS}/ngsi-ld/v1/entities \
#     -H 'Accept: */*' \
#     -H 'Content-Type: application/json' \
#     -H "Authorization: Bearer ${ACCESS_TOKEN_OPERATOR}" \
#     -d '{
#       "id": "urn:ngsi-ld:K8SCluster:fancy-marketplace",
#       "type": "K8SCluster",
#       "name": {
#         "type": "Property",
#         "value": "Fancy Marketplace Cluster"
#       },
#       "numNodes": {
#         "type": "Property",
#         "value": "3"
#       },
#       "k8sVersion": {
#         "type": "Property",
#         "value": "1.26.0"
#       }
#     }'

# echo -e "\n"

# export ACCESS_TOKEN_OPERATOR=$(./zz-pruebas_ejemplo-Fiwre/get_access_token_oid4vp.sh http://${GATEWAY_DNS} $OPERATOR_CREDENTIAL operator $certs_path);
# curl -s -X GET http://${GATEWAY_DNS}/ngsi-ld/v1/entities/urn:ngsi-ld:K8SCluster:fancy-marketplace \
    # -H 'Accept: */*' \
    # -H "Authorization: Bearer ${ACCESS_TOKEN_OPERATOR}" | jq '.'