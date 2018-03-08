#!/bin/bash

export ORDERER_URL={{ (index .Values.target.orderer.nodes 0).service.name }}:{{ (index .Values.target.orderer.nodes 0).service.internalPort }}
export CORE_PEER_MSPCONFIGPATH=/data/peerOrganizations/{{ .Values.target.org.domain}}/users/admin@{{ .Values.target.org.domain }}/msp

cd /data

{{- range .Values.consortium.channels }}
if [ ! -f /data/{{ .name }}.block ] ; then
  echo "Fetching config block and joining channel {{ .name }}"
  /data/script/waitForFile.sh {{ $.Values.consortium.name }} block/{{ .name }}.block /data/{{ .name }}.block
fi
export FABRIC_CFG_PATH=/etc/hyperledger/fabric
peer channel join -b {{ .name }}.block
{{- end }}

{{- range $i, $node := .Values.target.org.nodes }}
  {{ if eq $node.peerType "anchor"}}
    echo "Peer {{ $node.shortName }} is an anchor"
    {{- range $j, $channel := $.Values.consortium.channels }}
      {{- range $k, $org := $channel.orgs }}
        {{ if eq $.Values.target.org.name $org.name }}
          /data/script/checkForFile.sh {{ $.Values.consortium.name | lower }} \
                                      channel/{{ $channel.name }}-{{ $.Values.target.org.name }}-{{ $node.shortName }}-anchor.tx

          if [[ $? != 0 ]]; then
            echo "Creating anchor tx for channel {{ $channel.name }} and peer {{ $node.shortName }}"
            export FABRIC_CFG_PATH=/data
            configtxgen -profile {{ $channel.name }}Channel \
                        -outputAnchorPeersUpdate /data/{{ $channel.name }}-{{ $.Values.target.org.name }}-{{ $node.shortName }}-anchor.tx \
                        -channelID {{ $channel.name }} -asOrg {{ $.Values.target.org.mspid }}

            /data/script/shareFile.sh {{ $.Values.consortium.name | lower }} \
                                      channel/{{ $channel.name }}-{{ $.Values.target.org.name }}-{{ $node.shortName }}-anchor.tx \
                                      /data/{{ $channel.name }}-{{ $.Values.target.org.name }}-{{ $node.shortName }}-anchor.tx

            echo "Updating channel with anchor tx for {{ $channel.name }}"
            export FABRIC_CFG_PATH=/etc/hyperledger/fabric
            peer channel fetch newest -o ${ORDERER_URL} -c {{ $channel.name }} 
            peer channel update -o ${ORDERER_URL} -c {{ $channel.name }} -f /data/{{ $channel.name }}-{{ $.Values.target.org.name }}-{{ $node.shortName }}-anchor.tx 
          else
            echo "Peer anchor already set for {{ $node.shortName }}"
          fi
        {{- end }}
      {{- end }} 
    {{- end }}
  {{- end }}
{{- end }}