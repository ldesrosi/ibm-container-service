#!/bin/bash

if [ $# -ne 2 ];
  then
    echo "checkForFile.sh <CONSORTIUM> <FILE_NAME>"
    exit 255
fi

CONSORTIUM=$1
DATACENTER="{{ .Values.target.orderer.datacenter }}"
FILE_NAME=$2

{{ if .Values.cloudstorage }}
bx login --apikey {{ .Values.cloudstorage.iam.apikey }} -a {{ .Values.cloudstorage.iam.endpoint }}
TOKEN=$(bx iam oauth-tokens | grep "IAM token:" | cut -d " " -f5)

if curl "https://{{ .Values.cloudstorage.endpoint }}/${CONSORTIUM}/${FILE_NAME}" \
        -H "Authorization: Bearer ${TOKEN}" \
        --output /dev/null --silent --head --fail; then
  exit 0;
else
  exit 255;
fi
{{ else }}
  consul kv get -http-addr={{ .Values.consul.host }}:{{ .Values.consul.port }} -datacenter=${DATACENTER} ${CONSORTIUM}/${FILE_NAME}
  RESULT=$?
  if [[ ${RESULT} = 0 ]]; then
    exit 0;
  else 
    exit 255;
  fi        
done
{{ end }}



