#!/bin/bash

# Get the count of pods that are not in the '0/1' state
pod_count=$(oc get pods --selector=app=queue-management-api | awk '$2 != "0/1"'| wc -l)

# Check if the pod count is less than 4
if [ "$pod_count" -lt 5 ]; then
    echo "Pod count not met"
    exit 0
else
    # Get running pods starting with "queue-management-api"
    running_pods=$(oc get pods --field-selector=status.phase=Running --selector='app=queue-management-api' --output=jsonpath='{.items[*].metadata.name}' --sort-by=.metadata.creationTimestamp)
    
    if [ -z "$running_pods" ]; then
        echo "No running pods found for queue-management-api"
        exit 0
    fi

	# Find the oldest pod
	oldest_pod=$(echo "$running_pods" | awk '{print $1}')
	echo "Deleting the oldest running pod: $oldest_pod"
	oc delete pod "$oldest_pod"
fi
