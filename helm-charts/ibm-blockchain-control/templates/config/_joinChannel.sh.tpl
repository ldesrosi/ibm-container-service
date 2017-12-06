#!/bin/sh

if [ $# -ne 2 ]
  then
    echo "joinChannel.sh <ORG-NAME> <CHANNEL-NAME>"
    exit -1
fi

ORG=$1
CHANNEL=$2
export CORE_PEER_NETWORKID=nid1
export ORDERER_URL={{ $.Values.orderers.service.name }}:{{ $.Values.orderers.service.externalPort }}
export CORE_LOGGING_LEVEL=debug
export FABRIC_CFG_PATH=/etc/hyperledger/fabric
export GODEBUG="netdns=go"

export CORE_PEER_ADDRESS=blockchain-org1peer1:30110
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_MSPCONFIGPATH=/shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
source env.${ORG}.sh

peer channel fetch newest -o {{ $.Values.orderers.service.name }}:{{ $.Values.orderers.service.externalPort }} -c $CHANNEL 
peer channel join -b ${CHANNEL}_newest.block
