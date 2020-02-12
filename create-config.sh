#!/usr/bin/env bash
set -eux

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export SYS_DOMAIN=$1
export APPS_DOMAIN=$2

${SCRIPT_DIR}/create-certs.sh ${SYS_DOMAIN}

export PASSWORD=$(openssl rand -base64 18)
export WILD_SYS_CRT=$(cat ${SYS_DOMAIN}.crt | base64)
export WILD_SYS_KEY=$(cat ${SYS_DOMAIN}.key | base64)
export CA_CRT=$(cat ca.crt | base64)

envsubst <"${SCRIPT_DIR}/cf-install-values.yml.envsubst" >cf-install-values.yml
