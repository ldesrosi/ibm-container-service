#!/bin/bash

mkdir -p /tmp/identity/msp

chmod + x /rest-config/waitForService.sh && /rest-config/waitForService.sh {{  .Values.rest.ca.url }} 404

export FABRIC_CA_CLIENT_HOME=/tmp/identity/msp
fabric-ca-client enroll \
                     -u "http://{{  .Values.rest.ca.enrollment_id }}:{{  .Values.rest.ca.enrollment_password }}@{{ .Values.rest.ca.url }}" \
                     -M /tmp/identity/msp

PROFILE=/rest-config/composerProfile.json
CARD={{ .Values.rest.card.name }}
USER={{ .Values.rest.card.user }}
ROLE={{ .Values.rest.card.role }}
CERT=/tmp/identity/msp/signcerts/cert.pem
KEY=/tmp/identity/msp/keystore/$(ls /tmp/identity/msp/keystore/*_sk)

cd /home/composer/.composer

composer card create -f ${CARD}.card -p ${PROFILE} \
                     -u ${USER} -r ${ROLE} \
                     -c ${CERT} -k ${KEY}

composer card import -f ${CARD}.card

rm -rf /tmp/identity/msp