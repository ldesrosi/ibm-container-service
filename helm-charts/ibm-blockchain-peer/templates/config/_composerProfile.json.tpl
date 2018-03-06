{
    "name": "{{ .Values.consortium.name | lower }}",    
    "x-type": "hlfv1",
    "version": "1.0.0",
    "client": {
        "organization": "{{ .Values.target.org.name }}",
        "connection": {
            "timeout": {
                "peer": {
                    "endorser": "300",
                    "eventHub": "300",
                    "eventReg": "300"
                },
                "orderer": "300"
            }
        }
    },
    "channels": {
    {{ range $i, $channel := .Values.consortium.channels }}
        "{{ $channel.name }}": {
            "orderers": [
                {{- range $j, $orderer := $.Values.ordererOrganizations -}}
                {{- range $k, $node := $orderer.nodes }}
                "{{ $node.service.name }}.{{ $orderer.domain }}"{{if $k}},{{end}}
                {{- end -}}
                {{- if $j -}},{{- end -}}
                {{- end }}
            ],
            "peers": {
            {{- range $j, $org := $channel.orgs -}}
                {{- range $k, $node := $org.nodes }}
                "{{ $node.shortName }}.{{ $org.domain }}": {
                    "endorsingPeer": {{ $node.endorsingPeer }},
                    "chaincodeQuery": {{ $node.chaincodeQuery }},
                    "eventSource": {{ $node.eventSource }} 
                }{{ if not (or $j $k) }},{{- end -}}
                {{- end -}}
            {{- end }}
            }
        }
    {{- end }}
    },
    "organizations": {
        {{- range $i, $org := .Values.peerOrganizations }}
        "{{ $org.name }}": {
            "mspid": "{{ $org.mspid}}",
            "peers": [
                {{- range $j, $node := $org.nodes }}
                "{{ $node.shortName }}.{{ $org.domain }}"{{if $j}},{{end}}
                {{- end }}
            ],
            "certificateAuthorities": [
                "{{ $org.ca.name }}.{{ $org.domain }}"
            ]
        }{{if not $i }},{{ end -}}
        {{ end }}
    },
    "orderers": {
        {{- range $i, $orderer := .Values.ordererOrganizations -}}
        {{- range $j, $node :=  $orderer.nodes }}
        "{{ $node.service.name }}.{{ $orderer.domain }}": {
            "url": "grpc://{{ $node.service.name }}:{{ $node.service.internalPort }}",
            "grpcOptions": {
                "ssl-target-name-override": "{{ $node.service.name }}.{{ $orderer.domain }}"
            }
        }{{if or $i $j}},{{ end }}
        {{- end -}}
        {{- end }}
    },
    "peers": {
        {{- range $i, $org := .Values.peerOrganizations -}}
        {{- range $j, $node := $org.nodes }}
        "{{ $node.shortName }}.{{ $org.domain }}": {
            "url": "grpc://{{ $node.service.name }}:{{ $node.service.internalPort }}",
            "eventUrl": "grpc://{{ $node.service.name }}:{{ $node.service.eventInternalPort }}",
            "grpcOptions": {
                "ssl-target-name-override": "{{ $node.service.name }}.{{ $org.domain }}"
            }
        }{{if not (or $i $j)}},{{end}}
        {{- end -}}
        {{- end }}
    },
    "certificateAuthorities": {
        {{- range $i, $org := .Values.peerOrganizations }}
        "{{ $org.ca.name }}.{{ $org.domain }}": {
            "url": "http://{{ $org.ca.url }}",
            "caName": "{{ $org.ca.name }}",
            "httpOptions": {
                "verify": false
            }
        }{{if not $i}},{{end}}
        {{- end }}
    }
}