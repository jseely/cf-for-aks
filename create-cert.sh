#!/usr/bin/env bash
set -eux

key_name=$1
common_name=$2

openssl genrsa -out ${key_name}.key 2048
openssl req -new -key ${key_name}.key -subj "/CN=${common_name}" -out ${key_name}.csr
openssl x509 -req -in ${key_name}.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out ${key_name}.crt -days 99999
