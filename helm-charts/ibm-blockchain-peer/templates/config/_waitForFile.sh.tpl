#!/bin/bash

if [ $# -ne 3 ];
  then
    echo "shareCert.sh <CONSORTIUM> <FILE_NAME> <FILE_LOCATION>"
    exit 255
fi

CONSORTIUM=$1
FILE_NAME=$2
FILE_LOCATION=$3

echo "Waiting for file ${FILE_NAME} for Consortium ${CONSORTIUM}"

{{ if .Values.cloudstorage }}
bx login --apikey {{ .Values.cloudstorage.iam.apikey }} -a {{ .Values.cloudstorage.iam.endpoint }}
TOKEN=$(bx iam oauth-tokens | grep "IAM token:" | cut -d " " -f5)

while true
do
   if curl "https://{{ .Values.cloudstorage.endpoint }}/${CONSORTIUM}/${FILE_NAME}" \
            -H "Authorization: Bearer ${TOKEN}" \
            --output /dev/null --silent --head --fail; then

        curl "https://{{ .Values.cloudstorage.endpoint }}/${CONSORTIUM}/${FILE_NAME}" \
        -H "Authorization: Bearer ${TOKEN}" -o ${FILE_LOCATION}

        if [ -s ${FILE_LOCATION} ]; 
        then
          break;
        fi
  else
        sleep 5
  fi
done
{{ else }}
while true
do
  RESULT=$(redis-cli -h {{ .Values.redis.host }} -a {{ .Values.redis.password }} --raw exists ${CONSORTIUM}/${FILE_NAME}) 
  
  if [[ ${RESULT} = 1 ]]; then
    redis-cli -h {{ .Values.redis.host }} -a {{ .Values.redis.password }} get ${CONSORTIUM}/${FILE_NAME} | head -c -1 > ${FILE_LOCATION}
    break;
  else 
    printf '.' ;
    sleep 5
  fi        
done
{{ end }}