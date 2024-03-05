#!/bin/bash

# get the input values from the input json
eval "$(jq -r '@sh "OCP_VERSION=\(.ocp_version)"')"

# get the OpenShift version to install
VERSION=$(ibmcloud ks versions --show-version OpenShift | grep "$OCP_VERSION")

# Safely produce a JSON object containing the result value.
# jq will ensure that the value is properly quoted
# and escaped to produce a valid JSON string.
jq -n --arg version "$VERSION" '{"ocp_version":$version}'