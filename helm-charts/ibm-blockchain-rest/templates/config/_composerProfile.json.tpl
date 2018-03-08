{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
        {
            "url": "grpc://{{ .Values.ordererOrganizations.service.name }}:{{ .Values.ordererOrganizations.service.externalPort }}"
        }
    ],
    "ca": {
        "url": "http://{{ .Values.ca.url }}",
        "name": "{{ .Values.ca.name | lower }}"
    },
    "peers": [
        {{- range $i, $org := .Values.peerOrganizations }}        
        {{- range $j, $peer := $org.nodes }}
        {
            "requestURL": "grpc://{{ $peer.service.name }}:{{ $peer.service.externalPort }}",
            "eventURL": "grpc://{{ $peer.service.name }}:{{ $peer.service.eventExternalPort }}"
        }
        {{if $j}},{{end}}
        {{- end }}
        {{if $i}},{{end}}
        {{- end }}
    ],
    "mspID": "{{ .Values.rest.org.mspid }}",
    "channel": "{{ .Values.rest.channel }}",
    "timeout": 300
}