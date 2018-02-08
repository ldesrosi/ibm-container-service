#!/bin/bash

export FABRIC_CA_CLIENT_HOME=/data/clients

/data/script/waitForService.sh http://{{ .Values.ca.service.name }}:{{ .Values.ca.service.internalPort }} 404

if [ ! -f $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml ]; then
    # Create clients cert directory and copy the original identity file there
    mkdir /data/clients
    cp /ca-config/idlist.csv /data/clients

    # Enroll the CA identity to allow client requests to work.
    fabric-ca-client enroll -u "http://{{ .Values.ca.admin }}:{{ .Values.ca.password }}@{{ .Values.ca.service.name }}:{{ .Values.ca.service.internalPort }}" 
else 
    # Merge the original identity file with the one from ca-config
    cp /ca-config/idlist.csv /data/clients
fi

cd $FABRIC_CA_CLIENT_HOME

# Revoke identity not part of the list anymore
# TBC

# Create new identity that have been added to the list
OLDIFS=$IFS
IFS=";"
while read name secret type affiliation attrs
 do
   if [ "$name" != "Name" ]; then
      fabric-ca-client register --id.name $name --id.secret $secret --id.type $type --id.affiliation $affiliation --id.attrs $attrs
   fi
 done < /data/clients/idlist.csv
 IFS=$OLDIFS
