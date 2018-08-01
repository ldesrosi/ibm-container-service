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

# Register service
TAGS="\"Tags\": ["
{{- range .Values.target.orderer.nodes }}
   TAGS="\"${TAGS}{{.name}}\","
{{- end }}
TAGS="${TAGS::${#TAGS}-1}]"
curl -X PUT -d '{"Datacenter": "{{ $.Values.dc.name | lower }}", "Node": "{{ .Values.target.orderer.name }}", "Address": "{{ $.Values.dc.ip }}", "Service": { "Service": "{{ .Values.target.orderer.name }}", $TAGS, "Port": 30600 }}' http://{{ $.Values.consul.host }}:{{ $.Values.consul.port }}/v1/catalog/register

/data/script/shareFile.sh {{ $.Values.consortium.name | lower }} config/configtx.orderer.yaml /orderer-config/configtx.orderer.yaml
/data/script/setupMSP.sh

/data/script/waitForFile.sh {{ $.Values.consortium.name | lower }} block/orderer.block /data/orderer.block.base64
cat /data/orderer.block.base64 | base64 --decode > /data/orderer.block
rm /data/orderer.block.base64

find /data -type d | xargs chmod a+rx
find /data -type f | xargs chmod a+r
