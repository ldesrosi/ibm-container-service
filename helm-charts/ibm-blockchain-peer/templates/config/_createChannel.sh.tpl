#!/bin/bash

export FABRIC_CFG_PATH=/data
export ORDERER_URL={{ (index .Values.target.orderer.nodes 0).service.name }}:{{ (index .Values.target.orderer.nodes 0).service.internalPort }}
export CORE_PEER_MSPCONFIGPATH=/data/peerOrganizations/{{ .Values.target.org.domain}}/users/admin@{{ .Values.target.org.domain }}/msp
cd /data

{{- range .Values.consortium.channels }}
echo "Checking if {{ .name }}.tx has already been created."
/data/script/checkForFile.sh {{ $.Values.consortium.name }} channel/{{ .name }}.tx

if [ $? != 0 ]; then
  echo "Creating {{ .name }}.tx"
  configtxgen -profile {{ .name }}Channel -outputCreateChannelTx {{ .name }}.tx -channelID {{ .name }}
  /data/script/shareFile.sh {{ $.Values.consortium.name }} channel/{{ .name }}.tx /data/{{ .name }}.tx
fi
{{- end }}

export FABRIC_CFG_PATH=/etc/hyperledger/fabric
{{- range .Values.consortium.channels }}
/data/script/checkForFile.sh {{ $.Values.consortium.name }} block/{{ .name }}.block
if [ $? != 0 ]; then
  echo "Creating channel {{ .name }}"
  peer channel create -o ${ORDERER_URL} -c {{ .name }} -f /data/{{ .name }}.tx
  /data/script/shareFile.sh {{ $.Values.consortium.name }} block/{{ .name }}.block /data/{{ .name }}.block
fi
{{- end }}