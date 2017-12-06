#!/bin/bash

if [ $# -ne 3 ]
  then
    echo "createChannel.sh <ORG-NAME> <PROFILE> <CHANNEL-NAME>"
    exit -1
fi

ORG=$1
PROFILE=$2
export CHANNEL_NAME=$3

export ORDERER_URL={{ $.Values.orderers.service.name }}:{{ $.Values.orderers.service.externalPort }}
source /shared/env/${ORG}-env.sh

export FABRIC_CFG_PATH=/shared
configtxgen -profile ${PROFILE} -outputCreateChannelTx ${CHANNEL_NAME}.tx -channelID ${CHANNEL_NAME}

export FABRIC_CFG_PATH=/etc/hyperledger/fabric
peer channel create -o ${ORDERER_URL} -c ${CHANNEL_NAME} -f /shared/${CHANNEL_NAME}.tx