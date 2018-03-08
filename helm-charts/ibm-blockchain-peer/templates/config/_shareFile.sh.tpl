#!/bin/bash

if [ $# -ne 3 ];
  then
    echo "shareCert.sh <CONSORTIUM> <FILE_NAME> <FILE_LOCATION>"
    exit 255
fi

CONSORTIUM=$1
FILE_NAME=$2
FILE_LOCATION=$3

{{ if .Values.cloudstorage }}
bx login --apikey {{ .Values.cloudstorage.iam.apikey }} -a {{ .Values.cloudstorage.iam.endpoint }}
TOKEN=$(bx iam oauth-tokens | grep "IAM token:" | cut -d " " -f5)

curl -X "PUT" "https://{{ .Values.cloudstorage.endpoint }}/${CONSORTIUM}/${FILE_NAME}" \
 -H "Authorization: Bearer ${TOKEN}" \
 -H "Content-Type: application/x-pem-file" \
 --data-binary @"${FILE_LOCATION}"
{{ else }}
redis-cli -h {{ .Values.redis.host }} -a {{ .Values.redis.password }} -x set ${CONSORTIUM}/${FILE_NAME} < ${FILE_LOCATION} 
{{ end }}