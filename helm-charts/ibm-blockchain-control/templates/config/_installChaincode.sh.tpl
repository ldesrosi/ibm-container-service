#!/bin/bash

if [ $# -lt 4 ]
  then
    echo "deployChaincode.sh <ORG-NAME> <CHAINCODE> <VERSION> <LOCATION>\n"
    exit -1
fi

ORG=$1
CHAINCODE_NAME=$2
CHAINCODE_VERSION=$3
LOCATION=$4

export ORDERER_URL={{ $.Values.orderers.service.name }}:{{ $.Values.orderers.service.externalPort }}
source /shared/env/${ORG}-env.sh

peer chaincode install -n ${CHAINCODE_NAME} -v ${CHAINCODE_VERSION} -p ${LOCATION}