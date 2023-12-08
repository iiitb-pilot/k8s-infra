#!/bin/sh
# Copy configmaps from other namespaces
# DST_NS: Destination namespace 

COPY_UTIL=../../utils/copy_cm_func.sh
DST_NS=cattle-monitoring-system

kubectl -n $DST_NS create secret generic rancher-alert-slack-secret --from-literal=slack-webhook-secret="$1" --dry-run=client  -o yaml | kubectl apply -f -
$COPY_UTIL secret email-gateway msg-gateways $DST_NS
