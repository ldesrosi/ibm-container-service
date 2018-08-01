#/bin/bash

function waitForPodReadiness() {
    # Ensure arguments were passed
    if [[ ${#} -lt 1 ]]; then
        echo "Usage: ${FUNCNAME} <pod_name> [namespace]"
        return -1
    fi    
    echo "Waiting for pod ${1} to be ready."

    NAMESPACE=""
    if [[ ${#} -eq 2 ]]; then
       NAMESPACE="-n ${2}"
    fi
    until kubectl get pods ${NAMESPACE} -l component="${1}" -o jsonpath='{.items[*].status.phase}' | grep Running ;
    do 
       printf "."
       sleep 1 ; 
    done
    echo "Pod ${1} is running."
}

export DC_IP=""
function getDataCenterIP() {
    if [[ ${#} -ne 2 ]]; then
        echo "Usage: ${FUNCNAME} <bx-region> <cluster_name>"
        return 255
    fi
    echo "Setting region: ${1}"
    echo "Getting IP for cluster ${2}"

    bx target -r ${1}

    CLUSTER_INFO=$(bx cs workers ${2} --json)

    if echo  ${CLUSTER_INFO} | grep "FAILED" ; then
        exit 255
    else
        CLUSTER_INFO=[$(echo $CLUSTER_INFO | cut -d[ -f2-)
        export DC_IP=$(echo ${CLUSTER_INFO} | jq --raw-output '.[0].publicIP')
    fi
}

function setupEnv() {
    export DC_NAME=$1
    export K8S_CLUSTER=$2
    echo "ABout to setup datacenter $DC_NAME and cluster $K8S_CLUSTER"

    export KUBECONFIG="${HOME}/.bluemix/plugins/container-service/clusters/${K8S_CLUSTER}/kube-config-mil01-${K8S_CLUSTER}.yml"

    getDataCenterIP $DC_NAME $K8S_CLUSTER
}

function setupDatacenter() {
    if [[ ${#} -lt 2 ]]; then
        echo "Usage: ${FUNCNAME} <datacenter-name> <cluster_name> [peer-ip]"
        return 255
    fi
    setupEnv $@

    helm upgrade --install --namespace=default --values=./config/${DC_NAME}/consul.yaml --set "${WAN_PEER}AdvertiseWanIP=${DC_IP}" bc-service-discovery ../consul
    waitForPodReadiness bc-service-discovery-consul default
    DNS_IP=$(kubectl get pods -n default -l component=bc-service-discovery-consul -o jsonpath='{.items[*].status.podIP}')

    cp ./yaml/kube-dns.yaml .tmp-kube-dns.yaml
    echo "    {\"consul\": [\"${DNS_IP}:53\"]}" >> .tmp-kube-dns.yaml
    kubectl apply -n kube-system -f .tmp-kube-dns.yaml
    rm .tmp-kube-dns.yaml

    for dir in ./config/$DC_NAME/*/ ; do
        ORG_NAME="$(basename $dir)"
        echo "Now serving organization ${ORG_NAME}"
        kubectl create namespace $ORG_NAME
        kubectl -n $ORG_NAME apply -f ./yaml/role.yaml
    done

    WAN_PEER=""
    if [[ ${#} -eq 3 ]]; then
       WAN_PEER="WanPeerIP={$3},"
       echo "$ORG_NAME connecting to $WAN_PEER"
    fi

    echo "Data Center $DC_NAME is setup.  Worker IP is $DC_IP"
}


function setupFabric() {
    if [[ ${#} -lt 3 ]]; then
        echo "Usage: ${FUNCNAME} <datacenter-name> <cluster_name> <org-name>"
        return 255
    fi
    setupEnv $@
    ORG_NAME=$3
    ADDITIONAL_INSTR="$4"
    

    rm .*.yaml    

    if [ -f ./config/${DC_NAME}/${ORG_NAME}/ca.yaml ]; then
        cat ./config/infra.yaml ./config/${DC_NAME}/${ORG_NAME}/ca.yaml > .ca-${ORG_NAME}.yaml
        helm upgrade --install --namespace ${ORG_NAME} --values=.ca-${ORG_NAME}.yaml --set "dc.ip=${DC_IP},dc.name=${DC_NAME}" bc-${ORG_NAME}-ca ../ibm-blockchain-ca
    fi

    if [ -f ./config/${DC_NAME}/${ORG_NAME}/orderer.yaml ]; then
        cat ./config/infra.yaml ./config/network.yaml ./config/${DC_NAME}/${ORG_NAME}/orderer.yaml > .orderer-${ORG_NAME}.yaml
        helm upgrade --install --namespace ${ORG_NAME} --values=.orderer-${ORG_NAME}.yaml --set "dc.ip=${DC_IP},dc.name=${DC_NAME}" bc-${ORG_NAME}-orderer ../ibm-blockchain-orderer 
    fi

    if [ -f ./config/${DC_NAME}/${ORG_NAME}/peer.yaml ]; then
        cat ./config/infra.yaml ./config/network.yaml ./config/${DC_NAME}/${ORG_NAME}/peer.yaml > .peer-${ORG_NAME}.yaml
        helm upgrade --install --namespace ${ORG_NAME} --values=.peer-${ORG_NAME}.yaml --set "dc.ip=${DC_IP},dc.name=${DC_NAME}" --set "${ADDITIONAL_INSTR}" bc-${ORG_NAME}-peer ../ibm-blockchain-peer &
    fi
}

if [ $# -lt 3 ];
  then
    echo "${0} <function> [variable depending on function]"
    exit 255
fi

if [ $1 == "dc" ] ; then
    shift
    setupDatacenter $@
elif [ $1 == "fabric" ] ; then
    shift
    setupFabric $@
else 
    echo "Wrong input: ${1}"
fi
