#!/bin/bash

certificate_path=$1

function crate_ca_certificates {
    local ca_path=$1

    # Create the CA private key
    openssl genrsa -out $ca_path/ca.key 4096
    echo "[CA] - Private key created in $ca_path/ca.key"
    # Create the CA certificate
    openssl req -new -x509 -sha256 -days 365 -key $ca_path/ca.key -out $ca_path/ca.crt -subj "/C=ES/ST=Valencia/L=Valencia/O=UPV/OU=UPV/CN=upv.es"
    echo "[CA] - Certificate created in $ca_path/ca.crt"
}


# Check if data/ssl/ca exists and if not create it
if [ ! -d $certificate_path ]; then
    echo "[WORKING] - Creating folder and CA certificates in $certificate_path..."
    mkdir -p $certificate_path
    crate_ca_certificates $certificate_path
# Check if the CA certificates exists and if not create them
elif [ ! -f "$certificate_path/ca.key" ] || [ ! -f "$certificate_path/ca.crt" ]; then
    echo "[WORKING] - Creating CA certificates in $certificate_path..."
    crate_ca_certificates $certificate_path
fi
echo "[DONE] - CA certificates created."



