export CORE_LOGGING_LEVEL=debug
export FABRIC_CFG_PATH=/etc/hyperledger/fabric
export CORE_PEER_ADDRESSAUTODETECT=false
export CORE_PEER_NETWORKID=nid1
export CORE_PEER_LOCALMSPID={{ .org.id }}
export CORE_PEER_MSPCONFIGPATH=/shared/crypto-config/peerOrganizations/{{ .org.domain }}/users/Admin@{{ .org.domain }}/msp
{{- range $index, $service := .org.anchor_peers }}
export CORE_PEER_ADDRESS_{{ $index }}="{{ $service.service.name }}:{{ $service.service.externalPort }}"
{{- end }}
export CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS_0}