#!/bin/sh
set -e
. ./config

PASSPHRASE="$(kubectl get secret redpanda-admin-password -n rp --template '{{.data.password}}' | base64 -d)"

kubectl exec -it -n "${RP_NAMESPACE}" "statefulset/redpanda" -c redpanda -- \
    rpk -Xuser=admin -Xpass="${PASSPHRASE}" $@