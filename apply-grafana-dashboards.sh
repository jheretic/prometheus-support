#!/bin/bash
#
# apply-grafana-dashboards.sh updates the grafana-dashboard-provisioning and
# grafana-dashboards configmaps using configuration data from
# config/fedefation/grafana. This script assumes the target cluster credentials
# are already available.

# Create provisioning configuration for grafana dashboards.
kubectl create configmap grafana-dashboard-provisioning \
    --from-file=config/federation/grafana/provisioning/dashboards \
    --dry-run -o json | kubectl apply -f -

# Create conigmap for actual grafana dashboards.
#
# NOTE: We are piping the configmap data to `kubectl replace` here (instead of
# `kubectl create`) due to a limitation of the size of metadata.annotations in
# k8s. When using `create` we hit an error complaining about metadata.annotation
# exceeding 262144 characters. Using `replace` apparently overwrites old
# metadata allowing room for the new. We will still have a problem when the
# total size of the JSON files exceeds the maximium size for a ConfigMap (1MB).
kubectl create configmap grafana-dashboards \
    --from-file=config/federation/grafana/dashboards \
    --dry-run -o json | kubectl replace -f -
