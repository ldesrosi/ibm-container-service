#!/bin/bash

PROFILE=OrdererGenesis
export FABRIC_CFG_PATH=/data
export FABRIC_CA_CLIENT_HOME=/data

{{ if .Release.IsInstall }}
# We first ensure that the volume is clean from previous installs
rm -rf /data/*
{{ end }}

#Setup scripts in the shared folder
mkdir -p /data/script/
cp -f /peer-config/*.sh /data/script/
chmod +x /data/script/*.sh

#Setup connection profiles folder
mkdir -p /data/profile
cp -f /peer-config/*-ConnectionProfile.json /data/profile

# Setup the card folder
mkdir -p /data/card

# Register service
TAGS="\"Tags\": ["
TAG_ITEMS=""
{{- range .Values.target.org.nodes }}
   TAG_ITEMS="${TAG_ITEMS}\"{{.shortName}}\","
{{- end }}
TAGS="${TAGS}${TAG_ITEMS::${#TAG_ITEMS}-1}]"
echo $TAGS
curl -X PUT -d "{\"Datacenter\": \"{{ $.Values.dc.name | lower }}\", \"Node\": \"{{ .Values.target.org.name }}\", \"Address\": \"{{ $.Values.dc.ip }}\", \"Service\": { \"Service\": \"{{ .Values.target.org.name }}\", ${TAGS}, \"Port\": 31000 }}" http://{{ $.Values.consul.host }}:{{ $.Values.consul.port }}/v1/catalog/register

#Setup the MSP folders
/data/script/setupMSP.sh

find /data -type d | xargs chmod a+rx
find /data -type f | xargs chmod a+r

#Move configtx configuration files
/data/script/waitForFile.sh {{ .Values.consortium.name | lower }} config/configtx.orderer.yaml /data/configtx.orderer.yaml
cat /peer-config/configtx.yaml /data/configtx.orderer.yaml > /data/configtx.yaml
rm /data/configtx.orderer.yaml

{{ if .Values.generateGenesisBlock }}
# Setup genesis block
echo "Starting configtxgen" 
cd /data
configtxgen -profile $PROFILE -outputBlock orderer.block 

cat /data/orderer.block | base64 > /data/orderer.block.base64
/data/script/shareFile.sh {{ .Values.consortium.name | lower }} block/orderer.block /data/orderer.block.base64
rm /data/orderer.block.base64
{{ end }}


