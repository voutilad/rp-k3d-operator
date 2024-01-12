#!/bin/sh
##
## Deploy Redpanda, first creating any Secrets as needed.
##

. ./config

PASSPHRASE="$(./passphrase/generate.sh | tr -d '\n')"

if ! kubectl get secret redpanda-admin-password -n "${RP_NAMESPACE}" > /dev/null 2>&1; then
    kubectl create secret generic redpanda-admin-password -n "${RP_NAMESPACE}" \
        --from-literal-password="${PASSPHRASE}"
    echo ">> Created redpanda-admin-password secret"
fi

if ! kubectl get secret redpanda-superuser -n "${RP_NAMESPACE}" > /dev/null 2>&1; then
    kubectl create secret generic redpanda-superuser -n "${RP_NAMESPACE}" \
        --from-file=superusers.txt=/dev/stdin << EOF
admin:${PASSPHRASE}:SCRAM-SHA-256
EOF
    echo ">> Created redpanda-superuser secret"
fi

PASSPHRASE=""

if ! kubectl get redpandas redpanda -n "${RP_NAMESPACE}" > /dev/null 2>&1; then
    kubectl apply -f redpanda.yaml -n "${RP_NAMESPACE}"
    echo ">> Waiting for Redpanda statefulset to appear"
    while ! kubectl get statefulset redpanda -n "${RP_NAMESPACE}" > /dev/null 2>&1; do
        sleep 1
    done
    kubectl -n "${RP_NAMESPACE}" rollout status -w statefulset
    echo ">> Deployed Redpanda cluster via redpanda.yaml"
else
    echo ">> Redpanda cluster already deployed"
fi