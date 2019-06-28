#!/bin/bash

# basic test to verify if sync service was installed successfuly

namespace=${bamboo_namespace}

sync_service_pods() {
        kubectl get pods --namespace "$namespace" | grep "sync" | wc -l | sed 's/ *//'
}

count_pods=$(sync_service_pods)

if [ $count_pods == 2 ]
then
        echo "sync service it's installed!"
else
        echo "sync service it's not installed!"
        exit 1
fi
