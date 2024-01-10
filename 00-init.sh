#!/bin/sh

AGENTS="${AGENTS:-3}"
SERVERS="${SERVERS:-1}"
MEM="${MEM:-2G}"

# fire up cluster
if ! k3d cluster list redpanda 2>&1 > /dev/null; then
    k3d cluster create redpanda \
        --servers "${SERVERS}" --servers-memory "1.5g" \
        --agents "${AGENTS}" --agents-memory "${MEM}" \
        --registry-create rp-registry
else
    k3d cluster start redpanda --wait 2>&1 > /dev/null
fi

# update helm repos
if ! helm repo list | grep redpanda > /dev/null; then
    helm repo add redpanda https://charts.redpanda.com > /dev/null
fi
if ! helm repo list | grep jetstack > /dev/null; then
    helm repo add jetstack https://charts.jetstack.io > /dev/null
fi
helm repo update > /dev/null

if ! kubectl get service cert-manager -n cert-manager 2>&1 > /dev/null; then
    echo ">> Installing Cert-Manager..."
    kubectl create namespace cert-manager
    helm install cert-manager jetstack/cert-manager \
         --set installCRDs=true \
         --namespace cert-manager
    echo ">> Waiting for rollout..."
    kubectl -n cert-manager rollout status deployment cert-manager --watch
fi

kubectl cluster-info