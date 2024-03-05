expected_num_nodes=$1
#
# validate that the Node Feature Discovery instance found a GPU node
#
echo "Validating that the Node Feature Discovery instance found $expected_num_nodes GPU node(s)"

loop_count=0
until [[ $loop_count -gt 24 ]]
do
   echo "Checking nodes for the label 'feature.node.kubernetes.io/pci-10de.present'"
   results=$(kubectl get nodes -l feature.node.kubernetes.io/pci-10de.present -L feature.node.kubernetes.io/pci-10de.present 2>&1)
   if [[ $results == "No resources found" ]]
   then
      loop_count=$((loop_count+1))
      sleep 5
   else
      # get the number of lines returned. Looking for 1 more than the number of nodes to account for the header
      numlines=`echo "$results" | wc -l`
      if [[ $((numlines-1)) == $expected_num_nodes ]]
      then
         echo "Found $expected_num_nodes worker nodes with the NVIDIA GPU label"
         echo "$results"
         found=1
         break
      else
         loop_count=$((loop_count+1))
         sleep 5
      fi
   fi
done

if [[ $found == 0 ]]
then
   echo "Did not find $expected_num_nodes GPU nodes in the cluster!"
   kubectl get nodes -l feature.node.kubernetes.io/pci-10de.present -L feature.node.kubernetes.io/pci-10de.present
   exit 1
fi