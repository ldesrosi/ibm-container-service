#!/bin/bash

{{- range .Values.target.orderer.nodes }} 
/data/script/waitForService.sh grpc {{ .service.name }}:{{ .service.internalPort }} 56
{{- end }}

{{- range .Values.target.org.nodes }} 
/data/script/waitForService.sh grpc {{ .service.name }}:{{ .service.internalPort }} 56
{{- end }}

{{- range $i, $instr := .Values.instructions }}
echo "Running instruction {{ $instr }}"
/data/script/{{ $instr }}.sh

{{- end }}