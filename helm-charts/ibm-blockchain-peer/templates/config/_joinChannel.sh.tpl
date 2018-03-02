#!/bin/bash

export ORDERER_URL={{ (index .Values.target.orderer.nodes 0).service.name }}:{{ (index .Values.target.orderer.nodes 0).service.internalPort }}
export CORE_PEER_MSPCONFIGPATH=/data/peerOrganizations/{{ .Values.target.org.domain}}/users/admin@{{ .Values.target.org.domain }}/msp

cd /data

{{- range .Values.consortium.channels }}
if [ ! -f /data/{{ .name }}.block ] ; then
  echo "Fetching config block and joining channel {{ .name }}"
  /data/script/waitForFile.sh {{ $.Values.consortium.name }} block/{{ .name }}.block /data/{{ .name }}.block
  export FABRIC_CFG_PATH=/etc/hyperledger/fabric
  peer channel join -b {{ .name }}.block
fi
{{- end }}

{{- range $.Values.target.org.nodes }}

  {{ if eq .peerType "anchor"}}
    echo "Peer {{ .shortName }} is an anchor"
    {{- range $.Values.consortium.channels }}
      /data/script/checkForFile.sh {{ $.Values.consortium.name | lower }} \
                                   channel/{{ .name }}-{{ $.Values.target.org.name }}-anchor.tx

      if [[ $? != 0 ]]; then
        echo "Creating anchor tx for {{ .name }}"
        export FABRIC_CFG_PATH=/data
        configtxgen -profile {{ .name }}Channel \
                    -outputAnchorPeersUpdate /data/{{ .name }}-{{ $.Values.target.org.name }}-anchor.tx \
                    -channelID {{ .name }} -asOrg {{ $.Values.target.org.name }}

        /data/script/shareFile.sh {{ $.Values.consortium.name | lower }} \
                                  channel/{{ .name }}-{{ $.Values.target.org.name }}-anchor.tx \
                                  /data/{{ .name }}-{{ $.Values.target.org.name }}-anchor.tx

        echo "Updating channel with anchor tx for {{ .name }}"
        export FABRIC_CFG_PATH=/etc/hyperledger/fabric
        peer channel fetch newest -o ${ORDERER_URL} -c {{ .name }} 
        peer channel update -o ${ORDERER_URL} -c {{ .name }} -f /data/{{ .name }}-{{ $.Values.target.org.name }}-anchor.tx 
      else
        echo "Peer anchor already set for {{ .shortName }}"
      fi
    {{- end }}
  {{- end }}
{{- end }}