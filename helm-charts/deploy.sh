#/bin/bash

function waitForJobCompletion() {
    # Ensure arguments were passed
    if [[ ${#} -ne 1 ]]; then
        echo "Usage: ${FUNCNAME} <job_name>"
        return -1
    fi    
    echo "Waiting for job ${1} to complete."
    until kubectl get jobs --selector "job-name=${1}" \
                           -o jsonpath='{.items[*].status.succeeded}' \
                           | grep 1 ; 
    do 
       printf "."
       sleep 1 ; 
    done
    echo "Job ${1} has completed."
}

helm upgrade --install --set redisPassword=secretpassword --set persistence.enabled=false network-store stable/redis
helm upgrade --install --wait --values=./config/orderer/ca.yaml network-ca ibm-blockchain-ca
helm upgrade --install --wait --values=./config/org1/ca.yaml org1-ca ibm-blockchain-ca
helm upgrade --install --wait --values=./config/org2/ca.yaml org2-ca ibm-blockchain-ca
helm upgrade --install --values=./config/org1/peer.yaml --set "generateGenesisBlock=true,instructions={createChannel,joinChannel,deployComposerRuntime,deployBNA}" org1-peer ibm-blockchain-peer &
helm upgrade --install --values=./config/orderer/orderer.yaml network-orderer ibm-blockchain-orderer &
helm upgrade --install --values=./config/org2/peer.yaml --set "instructions={joinChannel,deployComposerRuntime}" org2-peer ibm-blockchain-peer &
