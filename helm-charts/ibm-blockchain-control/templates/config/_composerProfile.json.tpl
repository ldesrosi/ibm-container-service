    "ca": {
        "url": "http://{{ .service.name }}:{{ .service.externalPort }}",
        "name": "{{ .name | lower }}"
    },
    "peers": [
        {{- range .org.anchor_peers }}
        {

            "requestURL": "grpc://{{ .service.name }}:{{ .service.externalPort }}",
            "eventURL": "grpc://{{ .service.name }}:{{ .service.eventExternalPort }}"
        },
        {{- end }}
    ],
    "mspID": "{{ .org.id }}",