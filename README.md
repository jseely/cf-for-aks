# Deploy `cf-for-k8s` on AKS

1. Deploy a basic AKS cluster. (`cf-for-k8s` currently only support versions <1.16.0)
1. Create a build directory and cd into it `mkdir build && cd build`
1. Run the `create-config.sh` script (ex. `../create-config.sh sys.cf-for-k8s.example.com apps.cf-for-k8s.example.com`)
1. Connect to the cluster `az aks get-credentials ...`
1. Deploy cf-for-k8s `kapp deploy -a cf -f <(cat cf.kapp)`
