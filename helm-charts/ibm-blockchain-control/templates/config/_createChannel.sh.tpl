#!/bin/sh

if [ $# -ne 2 ]
  then
    echo "createChannel.sh <ORG-NAME> <CHANNEL-NAME>"
    exit -1
fi

ORG=$1
PROFILE=$3

export CHANNEL_NAME=$2
export ORDERER_URL={{ $.Values.orderers.service.name }}:{{ $.Values.orderers.service.externalPort }}

export CORE_PEER_ADDRESSAUTODETECT=false
export CORE_PEER_NETWORKID=nid1

export CORE_PEER_ADDRESS=blockchain-org1peer1:30110
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_MSPCONFIGPATH=/shared/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp

export CORE_LOGGING_LEVEL=debug
export FABRIC_CFG_PATH=/etc/hyperledger/fabric
export GODEBUG="netdns=go"

source env.${ORG}.sh

cd /shared && configtxgen -profile ${PROFILE} -outputCreateChannelTx ${CHANNEL}.tx -channelID ${CHANNEL}
## peer
cd /shared && peer channel create -o {{ .Values.orderers.service.name }}:{{ .Values.orderers.service.externalPort }} -c {{ .Values.channel.name }} -f /shared/{{ .Values.channel.name }}.tx