#!/bin/bash

# Get running pods starting with "queue-management-api"
running_pods=$(oc get pods --field-selector=status.phase=Running --selector='app=queue-management-api' --output=jsonpath='{.items[*].metadata.name}' --sort-by=.metadata.creationTimestamp)

if [ -z "$running_pods" ]; then
  echo "No running pods found for queue-management-api"
  exit 1
fi

# Find the oldest pod
oldest_pod=$(echo "$running_pods" | awk '{print $1}')
echo "Deleting the oldest running pod: $oldest_pod"
oc delete pod "$oldest_pod"
