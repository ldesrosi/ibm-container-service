#/bin/bash

function setupEnv() {
    export DC_NAME=$1
    export K8S_CLUSTER=$2
    echo "About to cleanup datacenter $DC_NAME and cluster $K8S_CLUSTER"

    export KUBECONFIG="${HOME}/.bluemix/plugins/container-service/clusters/${K8S_CLUSTER}/kube-config-mil01-${K8S_CLUSTER}.yml"
    ls $KUBECONFIG
}

function cleanupDc() {
    if [[ ${#} -lt 1 ]]; then
    echo "Usage: ${FUNCNAME} <datacenter-name> <cluster_name> <org-name>"
    return -1
    fi    
    setupEnv $@
    ORG_NAME=$3

    helm delete bc-service-discovery --purge
    kubectl delete -f ./yaml/kube-dns.yaml -n kube-system --ignore-not-found=true
    kubectl delete -f ./yaml/role.yaml -n ${ORG_NAME} --ignore-not-found=true


    echo "Checking for K8S objects to clean..."
    export OBJECTS=$(kubectl get jobs,pv,pvc -n ${ORG_NAME} --output name)
    if [[ ! -z "$OBJECTS" ]]; then
        echo "About to remove the following K8S objects: ${OBJECTS}"
        kubectl delete $OBJECTS -n ${ORG_NAME}
    fi
    kubectl delete namespace ${ORG_NAME} --ignore-not-found=true
}

function cleanupFabric() {
    if [[ ${#} -lt 3 ]]; then
        echo "Usage: ${FUNCNAME} <datacenter-name> <cluster_name> <org-name>"
        return 255
    fi
    setupEnv $@
    ORG_NAME=$3
    
    if [ -f ./config/${DC_NAME}/${ORG_NAME}/ca.yaml ]; then
        helm delete bc-${ORG_NAME}-ca --purge
    fi

    if [ -f ./config/${DC_NAME}/${ORG_NAME}/orderer.yaml ]; then
        helm delete bc-${ORG_NAME}-orderer --purge
    fi

    if [ -f ./config/${DC_NAME}/${ORG_NAME}/peer.yaml ]; then
        helm delete bc-${ORG_NAME}-peer --purge
    fi
}

if [ $# -lt 3 ];
  then
    echo "${0} <function> [variable depending on function]"
    exit 255
fi

if [ $1 == "dc" ] ; then
    shift
    cleanupDc $@
elif [ $1 == "fabric" ] ; then
    shift
    cleanupFabric $@
elif [ $1 == "all" ] ; then
    shift
    cleanupFabric $@
    cleanupDc $@
else 
    echo "Wrong input: ${1}"
fi





