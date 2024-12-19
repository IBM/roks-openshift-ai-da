#!/bin/bash
cluster=$1
num_workers=$2

# Function to get the list of worker nodes and their readiness status
get_worker_status() {
  # Get all nodes with the label 'node-role.kubernetes.io/worker'
  ibmcloud oc workers --cluster $1 --output json | jq '[.[] | "\(.id): \(.health.message)"]'
}

# Extract health messages and check if all are 'Ready'
loop=true
while $loop; do
  sleep 10
  json_output=$(get_worker_status $cluster)
  #echo $json_output

  # Check the number of elements in the JSON array
  worker_count=$(echo "$json_output" | jq '. | length')

  if [ "$worker_count" -ne $num_workers ]; then
    echo "Found $worker_count cluster workers. Looking for $num_workers workers."
    echo "Try again"
    continue
  else
    echo "Found $num_workers workers"
  fi

  # Loop through each element in the array
  INDEX=0
  all_ready=true
  while [ $INDEX -lt $worker_count ]; do
    # Extract the element at the current index
    element=$(echo "$json_output" | jq ".[$INDEX]")
    echo $element
    health_status=$(echo "$element" | awk -F": " '{print $2}' | awk '{print $1}')
    #echo $health_status

    if [ $health_status != "Ready\"" ]; then
      all_ready=false
    fi

    # Increment the index
    ((INDEX++))
  done

  # Check the overall result
  if $all_ready; then
    echo "Success: All $worker_count workers are 'Ready'."
    loop=false
  else
    echo "Not all workers are 'Ready' yet."
    echo "Try again"
  fi
done

echo "calling the Red Hat OpenShift AI add-on using the CLI for cluster $cluster"
ibmcloud oc cluster addon enable openshift-ai --cluster "$cluster" --param oaiInstallPlanApproval=Automatic --param oaiDeletePolicy=Delete --param oaiDashboard=Managed --param oaiKueue=Managed --param oaiCodeflare=Managed --param oaiModelmeshserving=Managed --param oaiWorkbenches=Managed --param oaiDataSciencePipelines=Managed --param oaiKserve=Managed --param oaiRay=Managed