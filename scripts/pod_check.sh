gpu_operator_namespace=$1
gpu_count=$2
rhods_cluster_namespace=$3

#wait a bit
echo "Waiting 5 minutes to let pods finish"
sleep 300

#dump all the pods in the gpu operator
echo ""
echo "The GPU operator pods may take up to 30 minutes to complete with many pods trying multiple times to complete successfully."
echo "This is normal. For many of the pods there will be one for each GPU enabled worker node."
echo "If at this point they are all not finished, check back later using the below command to get the pods"
echo "Current state of pods in the $gpu_operator_namespace namespace"
echo "To get this list execute this command: 'kubectl get pods -n $gpu_operator_namespace'"
kubectl get pods -n $gpu_operator_namespace

#dump all the pods in the rhods operator
echo ""
echo "Current state of pods in the $rhods_cluster_namespace namespace"
echo "To get this list execute this command: 'kubectl get pods -n $rhods_cluster_namespace'"
kubectl get pods -n $rhods_cluster_namespace

#check the nvidia-smi output of the first nvidia_driver_daemonset pod we find
echo ""
echo "Checking the GPU status of each GPU worker node"
echo "If the appropriate pods are up and running, the nvidia-smi output is provided."
echo "If they are not ready yet, come back and run the following command:"
echo "kubectl exec -n nvidia-gpu-operator nvidia-driver-daemonset-<uniqueID> -- nvidia-smi"
driver_daemonset_pods=$(kubectl get pods -o name -n $gpu_operator_namespace | grep nvidia-driver-daemonset 2>&1)
IFS=$'\n'
pods=($driver_daemonset_pods)
found=false
for (( i=0; i<${#pods[@]}; i++ ))
do
    echo "${pods[$i]}"
    pod="${pods[$i]}"
    pod_status=$(kubectl get "$pod" -n "$gpu_operator_namespace" -o jsonpath='{.status.phase}')
    if [[ $pod_status -eq "Running" ]]
    then
        found=true
        kubectl exec -n $gpu_operator_namespace $pod -- nvidia-smi
    fi
done

if [ "$found" = false ]
then
    echo "No nvidia-driver-daemonset pods were found in a Running state."
    echo "Come back later and check the status of the pods in the nvidia-gpu-opertor namespace"
fi