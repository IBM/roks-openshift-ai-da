eval "$(jq -r '@sh "RG_NAME=\(.rg_name) COS_NAME=\(.cos_name)"')"

#echo "rg = ${RG_NAME}"
#echo "cos = ${COS_NAME}"

OUTPUT=$(ibmcloud resource group $RG_NAME -q)
rg_status=$?
OUTPUT=$(ibmcloud resource service-instance "$COS_NAME")
cos_status=$?

if [[ $rg_status == 0 ]]; then
  create_rg="false"
else
  create_rg="true"
fi

if [[ $cos_status == 0 ]]; then
  create_cos="false"
else
  create_cos="true"
fi

jq -n --arg create_rg "$create_rg" --arg create_cos "$create_cos" '{"create_rg":$create_rg, "create_cos":$create_cos}'