#!/bin/bash

# temporary script
# rewrites the acs image with the one which contains the sync service amp

declare library_path

library_path="acs-k8s-cluster/scripts"

source "${library_path}/common.func.sh"

EDITION="$1"

namespace=$(get_namespace)

log_info "Change ACS installed image"

kubectl set image deployment "${bamboo_inject_release_name_acs}-alfresco-cs-repository" \
  alfresco-content-services=586394462691.dkr.ecr.eu-west-1.amazonaws.com/alfresco-sync-service-experiment:latest \
  --namespace=$namespace
