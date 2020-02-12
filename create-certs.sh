#!/usr/bin/env bash
set -eux
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

SYS_DOMAIN=$1

openssl genrsa -out ca.key 2048
openssl req -new -key ca.key -subj "/CN=ca" -out ca.csr
openssl x509 -req -in ca.csr -signkey ca.key -CAcreateserial  -out ca.crt -days 99999

${SCRIPT_DIR}/create-cert.sh ${SYS_DOMAIN} "*.${SYS_DOMAIN}"
