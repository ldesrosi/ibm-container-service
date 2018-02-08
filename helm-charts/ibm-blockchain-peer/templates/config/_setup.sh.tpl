#!/bin/bash

PROFILE=OrdererGenesis
export FABRIC_CFG_PATH=/data
export FABRIC_CA_CLIENT_HOME=/data

{{ if .Release.IsInstall }}
# We first ensure that the volume is clean from previous installs
rm -rf /data/*

#Setup scripts in the shared folder
mkdir /data/script/
cp /peer-config/*.sh /data/script/
chmod +x /data/script/*.sh

/data/script/setupMSP.sh

find /data -type d | xargs chmod a+rx
find /data -type f | xargs chmod a+r

#Move configtx configuration files
cp /peer-config/configtx.yaml /data/configtx.yaml

# Setup genesis block
echo "Starting configtxgen" 
cd /data
configtxgen -profile $PROFILE -outputBlock orderer.block 

{{ end }}


