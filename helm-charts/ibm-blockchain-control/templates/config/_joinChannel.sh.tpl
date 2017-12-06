#!/bin/bash

if [ $# -ne 2 ]
  then
    echo "joinChannel.sh <ORG-NAME> <CHANNEL-NAME>"
    exit -1
fi

ORG=$1
export CHANNEL_NAME=$2

export ORDERER_URL={{ $.Values.orderers.service.name }}:{{ $.Values.orderers.service.externalPort }}
source /shared/env/${ORG}-env.sh

peer channel fetch newest -o ${ORDERER_URL} -c ${CHANNEL_NAME} 
peer channel join -b ${CHANNEL_NAME}_newest.block
