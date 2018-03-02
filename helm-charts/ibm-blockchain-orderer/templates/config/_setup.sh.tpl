#!/bin/bash

PROFILE=OrdererGenesis
export FABRIC_CFG_PATH=/data
export FABRIC_CA_CLIENT_HOME=/data

{{ if .Release.IsInstall }}
# We first ensure that the volume is clean from previous installs
rm -rf /data/*
{{ end }}

mkdir -p /data/ledger

#Setup scripts in the shared folder
mkdir -p /data/script/
cp -f /orderer-config/*.sh /data/script/
chmod +x /data/script/*.sh

/data/script/shareFile.sh {{ $.Values.consortium.name | lower }} config/configtx.orderer.yaml /orderer-config/configtx.orderer.yaml
/data/script/setupMSP.sh

/data/script/waitForFile.sh {{ $.Values.consortium.name | lower }} block/orderer.block /data/orderer.block 

find /data -type d | xargs chmod a+rx
find /data -type f | xargs chmod a+r



