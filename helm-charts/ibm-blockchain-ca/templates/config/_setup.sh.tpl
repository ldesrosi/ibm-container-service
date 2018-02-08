#!/bin/bash

export FABRIC_CA_HOME=/data/cas

{{ if .Release.IsInstall }}
# We first ensure that the volume is clean from previous installs
rm -rf /data/*
mkdir /data/cas
mkdir /data/script
cp /ca-config/waitForService.sh /data/script/waitForService.sh
chmod +x /data/script/waitForService.sh

{{ end }}

#Move certificate authority configuration files
cp /ca-config/ca.yaml /data/cas/fabric-ca-server-config.yaml
PATTERN='/ca-config/*-ca.yaml'
for filename in $PATTERN; do
  if [ "$filename" = "$PATTERN" ]; then
     break
  fi

  name=${filename##*/}
  subca_dir=${name%-ca.yaml}

  mkdir -p /data/cas/$subca_dir
  cp $filename /data/cas/$subca_dir/ca.yaml
done

{{ if .Release.IsInstall }}
# Initializing the certificate authority
echo "Initializing fabric-ca" 
{{ if .Values.ca.root }}
fabric-ca-server init -b {{ .Values.ca.admin }}:{{ .Values.ca.password }} \
                      -u http://{{ .Values.ca.admin }}:{{ .Values.ca.password }}@{{ .Values.ca.root.hostname }}:{{ .Values.ca.root.port }}
{{ else }}
fabric-ca-server init -b {{ .Values.ca.admin }}:{{ .Values.ca.password }}
{{ end }}
{{ end }}


