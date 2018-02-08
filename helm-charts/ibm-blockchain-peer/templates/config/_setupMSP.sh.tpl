#!/bin/bash

export FABRIC_CFG_PATH=/data
export FABRIC_CA_CLIENT_HOME=/data

# Script is missing a few things:  TLS Certs and Users other then Admin

# Setup Orderer MSP
{{ range .Values.ordererOrganizations }}
mkdir -p /data/ordererOrganizations/{{ .domain }}/msp
mkdir -p /data/ordererOrganizations/{{ .domain }}/users
mkdir -p /data/ordererOrganizations/{{ .domain }}/orderers/{{ .name }}.{{ .domain }}/msp/

# Wait for Orderer CA to be up and then retrive the CA Root and Intermediary CAs
/data/script/waitForService.sh {{ .ca.url }} 404
fabric-ca-client getcacert -u "http://{{ .ca.url }}" -M /data/ordererOrganizations/{{ .domain }}/msp

{{ if .ca.node }}
# Enrolling orderer's node identity
fabric-ca-client enroll \
                 -u "http://{{ .ca.node.enrollment_id }}:{{ .ca.node.enrollment_password }}@{{ .ca.url }}" \
                 -M /data/ordererOrganizations/{{ .domain }}/orderers/{{ .name }}.{{ .domain }}/msp 
{{ else }}
# Copying over the CA info the the orderer node msp
cp -pR /data/ordererOrganizations/{{ .domain }}/msp /data/ordererOrganizations/{{ .domain }}/orderers/{{ .name }}.{{ .domain }}/msp
{{ end }}

{{ if .ca.admin }}
# Preparing orderer's admin msp
ADMIN_MSP_DIR=/data/ordererOrganizations/{{ .domain }}/users/{{.ca.admin.enrollment_id}}@{{ .domain }}/msp
mkdir -p $ADMIN_MSP_DIR

{{ if .ca.admin.enrollment_password }}
# Enrolling orderer's admin identity and sharing cert on cloud storage
fabric-ca-client enroll \
                 -u "http://{{ .ca.admin.enrollment_id }}:{{ .ca.admin.enrollment_password }}@{{ .ca.url }}" \
                 -M $ADMIN_MSP_DIR
/data/script/shareFile.sh {{ $.Values.consortium.name | lower }} {{ .ca.admin.enrollment_id }} \
                          $ADMIN_MSP_DIR/signcerts/cert.pem
{{ else }}
# Copying over the CA info to the orderer admin msp
cp -pR /data/ordererOrganizations/{{ .domain }}/msp/ $ADMIN_MSP_DIR
mkdir -p $ADMIN_MSP_DIR/signcerts
/data/script/waitForFile.sh {{ $.Values.consortium.name | lower }} {{ .ca.admin.enrollment_id }} \
                            $ADMIN_MSP_DIR/signcerts/cert.pem
{{ end }}

# Distributing Orderer's Admin cert across org and node's MSP
mv $ADMIN_MSP_DIR/signcerts/cert.pem $ADMIN_MSP_DIR/signcerts/{{.ca.admin.enrollment_id}}@{{ .domain }}.pem
cp -pR $ADMIN_MSP_DIR/signcerts $ADMIN_MSP_DIR/admincerts
cp -pR $ADMIN_MSP_DIR/admincerts /data/ordererOrganizations/{{ .domain }}/msp/admincerts
cp -pR $ADMIN_MSP_DIR/admincerts /data/ordererOrganizations/{{ .domain }}/orderers/{{ .name }}.{{ .domain }}/msp/admincerts
{{ end }}
{{ end }}

# Setup Org and Peers MSPs
{{ range .Values.peerOrganizations }}  
{{- $domain := .domain -}}
mkdir -p /data/peerOrganizations/{{ $domain }}/msp
mkdir -p /data/peerOrganizations/{{ $domain }}/users
mkdir -p /data/peerOrganizations/{{ $domain }}/peers

# Retrieve CA Certs for the organization
/data/script/waitForService.sh {{ .ca.url }} 404
fabric-ca-client getcacert -u "http://{{ .ca.url }}" -M /data/peerOrganizations/{{ $domain }}/msp

{{ if .ca.admin }}
# Create organization's Admin MSP
ADMIN_MSP_DIR=/data/peerOrganizations/{{ $domain }}/users/{{.ca.admin.enrollment_id}}@{{ $domain }}/msp
mkdir -p $ADMIN_MSP_DIR

{{ if .ca.admin.enrollment_password }}
# Enroll organization's Admin and share the cert
fabric-ca-client enroll \
                 -u "http://{{ .ca.admin.enrollment_id }}:{{ .ca.admin.enrollment_password }}@{{ .ca.url }}" \
                 -M $ADMIN_MSP_DIR
/data/script/shareFile.sh {{ $.Values.consortium.name | lower }} {{ .ca.admin.enrollment_id }} \
                          $ADMIN_MSP_DIR/signcerts/cert.pem
{{ else }}
# Populate CA Certs for the organization's MSP and retrieve the shared cert  
cp -pR /data/peerOrganizations/{{ $domain }}/msp/* $ADMIN_MSP_DIR
mkdir -p $ADMIN_MSP_DIR/signcerts
/data/script/waitForFile.sh {{ $.Values.consortium.name | lower }} {{ .ca.admin.enrollment_id }} \
                            $ADMIN_MSP_DIR/signcerts/cert.pem
{{ end }}

# Distributing Organization's Admin cert across org and node's MSP   
mv $ADMIN_MSP_DIR/signcerts/cert.pem $ADMIN_MSP_DIR/signcerts/{{.ca.admin.enrollment_id}}@{{ $domain }}.pem
cp -pR $ADMIN_MSP_DIR/signcerts $ADMIN_MSP_DIR/admincerts
cp -pR $ADMIN_MSP_DIR/admincerts /data/peerOrganizations/{{ $domain }}/msp/admincerts
{{ end }}

{{- range .nodes}}
PEER_MSP_DIR=/data/peerOrganizations/{{ $domain }}/peers/{{ .shortName }}.{{ $domain }}/msp
mkdir -p $PEER_MSP_DIR
{{ if .ca.node }}
fabric-ca-client enroll \
                 -u "http://{{ .ca.node.enrollment_id }}:{{ .ca.node.enrollment_password }}@{{ .ca.url }}" \
                 -M $PEER_MSP_DIR
{{ else }}
cp -pR /data/peerOrganizations/{{ $domain }}/msp/ $PEER_MSP_DIR
{{ end }}
cp -pR $ADMIN_MSP_DIR/admincerts $PEER_MSP_DIR/admincerts
{{ end }}

{{ end }}