#!/usr/bin/env bash
set -eux

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export SYS_DOMAIN=$1
export APPS_DOMAIN=$2

# Create CA if one does not exist in the current directory
if ! ( test -f ca.crt && test -f ca.key ); then
  openssl genrsa -out ca.key 2048
  openssl req -new -key ca.key -subj "/CN=ca" -out ca.csr
  openssl x509 -req -in ca.csr -signkey ca.key -CAcreateserial  -out ca.crt -days 99999
fi

create_cert ()
{
  file_name=$1
  subj=$2

  openssl genrsa -out ${file_name}.key 2048
  openssl req -new -key ${file_name}.key -subj "${subj}" -out ${file_name}.csr
  openssl x509 -req -in ${file_name}.csr -CA ca.crt -CAkey ca.key -CAcreateserial  -out ${file_name}.crt -days 99999

  export CERTS_$file_name="$(cat ${file_name}.crt | base64)"
  export KEYS_$file_name="$(cat ${file_name}.key | base64)"
}

create_cert "sys" "/CN=*.${SYS_DOMAIN}"
create_cert "log_cache" "/CN=log-cache"
create_cert "log_cache_syslog" "/CN=log-cache-syslog"
create_cert "log_cache_gateway" "/CN=log-cache-gateway"
create_cert "log_cache_metrics" "/CN=log-cache-metrics"

export PASSWORD=$(openssl rand -base64 18)
export CA_CRT=$(cat ca.crt | base64)
export CA_KEY=$(cat ca.key | base64)

envsubst <"${SCRIPT_DIR}/cf-install-values.yml.envsubst" >cf-install-values.yml
ytt -f "${SCRIPT_DIR}/cf-for-k8s/config" -f cf-install-values.yml > cf.kapp
