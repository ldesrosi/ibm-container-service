#!/bin/bash

{{ range $i, $channel := .Values.consortium.channels }}
{{ range $j, $bna := $channel.bnas }}
mkdir -p /data/channels/{{ $channel.name }}/
curl -L -f {{ $bna.bna_url }} -o /data/channels/{{ $channel.name }}/network.bna
curl -L -f {{ $bna.endorsement_url }} -o /data/channels/{{ $channel.name }}/endorsement.json

ENDORSEMENT_POLICIES=""
if [ -f /data/channels/{{ $channel.name }}/endorsement.json ]; then
  ENDORSEMENT_POLICIES="-o endorsementPolicyFile=/data/channels/{{ $channel.name }}/endorsement.json"
fi

{{ range $k, $admin := $bna.admins }}
/data/script/waitForFile.sh {{ $.Values.consortium.name }} cert/{{ $admin.id }} \
                            /data/channels/{{ $channel.name }}/{{ $admin.id }}-pub.pem
{{ end }}

composer network start -c PeerAdmin@{{ $.Values.consortium.name | lower }} \
                       -a /data/channels/{{ $channel.name }}/network.bna ${ENDORSEMENT_POLICIES} \
                       {{- range $k, $admin := $bna.admins }}
                       -A {{ $admin.id }} -C /data/channels/{{ $channel.name }}/{{ $admin.id }}-pub.pem {{if not $k}}\{{end}}
                       {{- end }}
{{ end }}
{{ end }}