#!/usr/bin/env bash
check_variable() {
  case "${!1}" in
    '')
      echo "$1: not set. Please set a value for this variable."
      exit 1;;
  esac
}

check_variable SUBSCRIPTION
check_variable RESOURCE_GROUP
check_variable LOCATION
check_variable SYS_DOMAIN
check_variable APPS_DOMAIN

set -eu
ARCH_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
REPO_DIR="$( cd "$ARCH_DIR/.." >/dev/null 2>&1 && pwd )"

az account set --subscription $SUBSCRIPTION
az group create -n $RESOURCE_GROUP -l $LOCATION
sp_object=$(az ad sp create-for-rbac -n $RESOURCE_GROUP --role contributor --scopes "/subscriptions/${SUBSCRIPTION}/resourceGroups/${RESOURCE_GROUP}")
az group deployment create -g $RESOURCE_GROUP --template-file "$ARCH_DIR/azureDeploy.json" --parameters servicePrincipalClientId=$(echo $sp_object | jq -r '.appId') servicePrincipalClientSecret=$(echo $sp_object | jq -r '.password')
sleep 10
az aks get-credentials -g $RESOURCE_GROUP -n ${RESOURCE_GROUP}-cluster

${REPO_DIR}/create-config.sh $SYS_DOMAIN $APPS_DOMAIN
kapp deploy -a $RESOURCE_GROUP -y -f <(cat cf.kapp) || echo "Deployment may sometimes timeout due to the number of components being deployed. (Run the following command to retry deployment of components that have timedout in kubernetes: 'kubectl get po -n cf-system | grep CrashLoopBackOff | awk '{print \$1}' | xargs -I {} kubectl delete po -n cf-system {}'"
echo ""
echo "Please configure your A Records for '*.${SYS_DOMAIN}' and '*.${APPS_DOMAIN}' to point to '$(kubectl get service -n istio-system istio-ingressgateway | grep LoadBalancer | awk '{print $4}')'."
echo "You should then be able to target the CF API using 'cf api --skip-ssl-validation https://api.${SYS_DOMAIN}' and log in using 'cf auth admin \"$(cat cf-install-values.yml | grep cf_admin_password | awk '{print $2}')\"'"
