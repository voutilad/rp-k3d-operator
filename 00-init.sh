#!/bin/sh
##
## Bootstrap a k3s cluster using k3d, annotate the nodes with zones, install 
## cert-manager, and the Redpanda CRDs.
##

set -e
. ./config

# Fire up a cluster
if ! k3d cluster list redpanda > /dev/null 2>&1; then
    k3d cluster create redpanda \
        --servers "${SERVERS}" --servers-memory "1.5g" \
        --agents "${AGENTS}" --agents-memory "${MEM}" \
        --registry-create rp-registry
else
    k3d cluster start redpanda --wait > /dev/null 2>&1 
fi

# Annotate K3s agent nodes
for idx in 0 1 2; do
    kubectl annotate node "k3d-redpanda-agent-${idx}" "topology.kubernetes.io/zone=rack${i}"
done
echo ">> Annotated k3s agent nodes with zones"

# Update helm repos
if ! helm repo list | grep redpanda > /dev/null; then
    helm repo add redpanda https://charts.redpanda.com > /dev/null
fi
if ! helm repo list | grep jetstack > /dev/null; then
    helm repo add jetstack https://charts.jetstack.io > /dev/null
fi
helm repo update > /dev/null

# Install Cert-Manager
if ! kubectl get service cert-manager -n cert-manager > /dev/null 2>&1; then
    echo ">> Installing Cert-Manager..."
    kubectl create namespace cert-manager
    helm install cert-manager jetstack/cert-manager \
         --set installCRDs=true \
         --namespace cert-manager
    echo ">> Waiting for rollout..."
    kubectl -n cert-manager rollout status deployment cert-manager --watch
fi

# Install Redpanda CRDs
kubectl kustomize "https://github.com/redpanda-data/redpanda-operator/src/go/k8s/config/crd?ref=${RP_OPERATOR_VERSION}" \
	| kubectl apply -f -

kubectl cluster-info