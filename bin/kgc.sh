#!/usr/bin/env sh

set -euo pipefail

usage="Usage: helm $HELM_PLUGIN_NAME ConfigMapName"

if [ "$#" -eq 1 ] ; then
    continue
else
    echo $usage
    exit 1
fi

#SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

$HELM_PLUGINS/$HELM_PLUGIN_NAME/bin/kubectl get cm "$1" -n $HELM_NAMESPACE -o='jsonpath={.data.values\.yaml}'
