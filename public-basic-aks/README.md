# Public Internet facing CF for K8s

This reference architecture deploys CF For K8s on an AKS cluster with a basic networking configuration. All traffic is expected to come from the public internet and go to the public internet for both management and application networking.As such, this architecture is recommended for Proof of Concept deployments and deployments without hard security considerations.

## Deploying

To deploy this solution run the `./deploy.sh` script from this directory in a directory you would like to save all deployment artifacts. You will need the following environment variables set:

* `SUBSCRIPTION`: The Azure subscription id to deploy into
* `RESOURCE_GROUP`: The Azure resource group name to deploy into
* `SYSTEM_DOMAIN`: The system domain for the cloud foundry deployment
* `APPS_DOMAIN`: The application domain for the cloud foundry deployment  

### Dependencies

Before running this deployment script ensure the following tools are installed.

1. [`ytt`](https://github.com/k14s/ytt) - YAML Templating cli
1. [`kapp`](https://github.com/k14s/kapp) - Lightweight deployment tool for Kubernetes
1. `envsubst` - Tool for injecting environment variables into files
1. `jq` - Tool for parsing JSON documents
1. [`az` cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) - CLI tool for interacting with Azure

You will also need to ensure that the `cf-for-k8s` git submodule has been checked out at the root of this repository. (`git submodule update --init --recursive`)
