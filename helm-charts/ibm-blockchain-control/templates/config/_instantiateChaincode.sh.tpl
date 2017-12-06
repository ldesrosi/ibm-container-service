#!/bin/bash

if [ $# -lt 4 ]
  then
    echo "deployChaincode.sh <ORG-NAME> <CHAINCODE> <VERSION> <CHANNEL-NAME> [<PARAM>]\n"
    exit -1
fi

ORG=$1
CHAINCODE_NAME=$2
CHAINCODE_VERSION=$3
PARAM=$5

export CHANNEL_NAME=$4
export ORDERER_URL={{ $.Values.orderers.service.name }}:{{ $.Values.orderers.service.externalPort }}
source /shared/env/${ORG}-env.sh

if [ $# -lt 5 ]
  then
    peer chaincode instantiate -o ${ORDERER_URL} -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -v ${CHAINCODE_VERSION}
  else
    peer chaincode instantiate -o ${ORDERER_URL} -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -v ${CHAINCODE_VERSION} -c "${PARAM}"
fi

