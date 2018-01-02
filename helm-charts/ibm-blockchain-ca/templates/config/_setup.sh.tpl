#!/bin/sh

export FABRIC_CA_HOME=/ca/cas

{{ if .Release.IsInstall }}
# We first ensure that the volume is clean from previous installs
rm -rf /ca/*
touch /ca/cleanup.done
{{ end }}

#Move certificate authority configuration files
mkdir /ca/cas
cp /ca-config/ca.yaml /ca/cas/ca.yaml
for filename in /ca-config/*-ca.yaml; do
  name=${filename##*/}
  subca_dir=${name%-ca.yaml}

  mkdir /ca/cas/$subca_dir
  cp $filename /ca/cas/$subca_dir/ca.yaml
done

{{ if .Release.IsInstall }}
# Initializing the certificate authority
echo "Initializing fabric-ca" 
{{ if .Values.ca.main.root }}
fabric-ca-server init -b {{ .Values.ca.admin }}:{{ .Values.ca.password }} \
                      -u http://{{ .Values.ca.admin }}:{{ .Values.ca.password }}@{{ .Values.ca.main.root.hostname }}:{{ .Values.ca.main.root.port }} \
                      --cafiles /ca/cas/ca.yaml
{{ else }}
fabric-ca-server init -b {{ .Values.ca.admin }}:{{ .Values.ca.password }} --cafiles /ca/cas/ca.yaml
{{ end }}
{{ end }}


