#!/bin/sh

if [ $# -lt 4 ]
  then
    echo "deployChaincode.sh <ORG-NAME> <CHAINCODE> <VERSION> <LOCATION> <CHANNEL-NAME> <PARAM>\n"
    echo "Providing channel will instantiate the chaincode"
    exit -1
fi

ORG=$1
CHAINCODE_NAME=$2
CHAINCODE_VERSION=$3
LOCATION=$4
CHANNEL=$5
PARAM=$6

export FABRIC_CFG_PATH=/etc/hyperledger/fabric
export GODEBUG="netdns=go"

export CORE_PEER_ADDRESS=blockchain-org1peer1:30110
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_MSPCONFIGPATH=/shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp

source env.${ORG}.sh

peer chaincode install -n $CHAINCODE -v $VERSION -p $LOCATION

if [$# -gt 4]
   then 
        if [$# -eq 5]
        then
            peer chaincode instantiate -o {{ $.Values.orderers.service.name }}:{{ $.Values.orderers.service.externalPort }} \
                                        -C $CHANNEL -n $CHAINCODE -v $VERSION 
        else
            peer chaincode instantiate -o {{ $.Values.orderers.service.name }}:{{ $.Values.orderers.service.externalPort }} \
                                        -C $CHANNEL -n $CHAINCODE -v $VERSION -c $PARAM
        fi
   fi
