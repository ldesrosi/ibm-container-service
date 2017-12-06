    "ca": {
        "url": "http://{{ .service.name }}:{{ .service.externalPort }}",
        "name": "{{ .name | lower }}"
    },
    "peers": [
        {{- range $i, $peer := .org.anchor_peers }}
        {

            "requestURL": "grpc://{{ $peer.service.name }}:{{ $peer.service.externalPort }}",
            "eventURL": "grpc://{{ $peer.service.name }}:{{ $peer.service.eventExternalPort }}"
        }
        {{if $i}},{{end}}
        {{- end }}
    ],
    "mspID": "{{ .org.id }}",