#!/bin/bash

cd /data/card

ADMIN_MSP_DIR=/data/peerOrganizations/{{ .Values.target.org.domain }}/users/admin@{{ .Values.target.org.domain }}/msp
ADMIN_CERT=${ADMIN_MSP_DIR}/signcerts/admin@{{ .Values.target.org.domain }}.pem
ADMIN_KEY_LIST=( ${ADMIN_MSP_DIR}/keystore/* )
ADMIN_KEY=${ADMIN_KEY_LIST[0]}

composer card create -p /data/profile/{{ .Values.target.org.name }}-ConnectionProfile.json \
                     -u PeerAdmin -c ${ADMIN_CERT} -k ${ADMIN_KEY} \
                     -r PeerAdmin -r ChannelAdmin \
                     -f /data/card/PeerAdmin@{{ .Values.consortium.name | lower }}.card

composer card import -f /data/card/PeerAdmin@{{ .Values.consortium.name | lower }}.card

{{ range $i, $channel := .Values.consortium.channels }}
{{ range $j, $bna := $channel.bnas }}
composer runtime install -c PeerAdmin@{{ $.Values.consortium.name | lower }} -n {{ $bna.name }}

{{ range $k, $admin := $bna.admins }}
{{ if $admin.enrolment_id }}
composer identity request -c PeerAdmin@{{ $.Values.consortium.name | lower }} -u {{ $admin.enrolment_id }} -s {{ $admin.enrolment_password }} -d {{ $admin.id }}

composer card create -p /data/profile/{{ $.Values.target.org.name }}-ConnectionProfile.json \
                     -u {{ $admin.id }} -n {{ $bna.name }} -c {{ $admin.id }}/{{ $admin.enrolment_id }}-pub.pem \
                     -k {{ $admin.id }}/{{ $admin.enrolment_id }}-priv.pem \
                     -f /data/card/{{ $admin.id }}@{{ $.Values.consortium.name | lower }}.card

/data/script/shareFile.sh {{ $.Values.consortium.name }} cert/{{ $admin.id }} \
                          {{ $admin.id }}/{{ $admin.enrolment_id }}-pub.pem
{{ end }}
{{ end }}
{{ end }}
{{ end }}