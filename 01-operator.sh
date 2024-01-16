#!/bin/sh
##
## Deploys the Redpanda Operator.
##

set -e
. ./config

if ! kubectl get deployment "redpanda-controller-operator" > /dev/null 2>&1; then
    echo ">> Installing Redpanda Operator ${RP_OPERATOR_VERSION}"
    if ! kubectl get namespace "${RP_NAMESPACE}" > /dev/null 2>&1; then
        kubectl create namespace "${RP_NAMESPACE}"
    fi
    helm install -f "operator-${RP_OPERATOR_VERSION}.yaml" redpanda-controller \
        "redpanda/operator" -n "${RP_NAMESPACE}"
    kubectl -n "${RP_NAMESPACE}" rollout status \
        -w "deployment/redpanda-controller-operator"
else
    echo ">> Operator already installed"
fi

