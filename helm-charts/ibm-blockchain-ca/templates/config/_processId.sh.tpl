#!/bin/bash

export FABRIC_CA_CLIENT_HOME=/ca/clients

echo "Trying to contact http://{{ .Values.ca.main.service.name }}:{{ .Values.ca.main.service.internalPort }}"
while true ; do
   STATUS="$(curl -s -w %{http_code} -o /dev/null --connect-timeout 2 http://{{ .Values.ca.main.service.name }}:{{ .Values.ca.main.service.internalPort }})"
   if [ "${STATUS}" == "404" ]; then
       echo "Service is up and running."
       echo "Proceeding with identities registration."
       break
   else
       sleep 2
       echo "."
   fi
done

if [ ! -f $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml ]; then
    # Create clients cert directory and copy the original identity file there
    mkdir /ca/clients
    cp /ca-config/idlist.csv /ca/clients

    # Enroll the CA identity to allow client requests to work.
    fabric-ca-client enroll -u "http://{{ .Values.ca.admin }}:{{ .Values.ca.password }}@{{ .Values.ca.main.service.name }}:{{ .Values.ca.main.service.internalPort }}" 
else 
    # Merge the original identity file with the one from ca-config
    cp /ca-config/idlist.csv /ca/clients
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
 done < /ca/clients/idlist.csv
 IFS=$OLDIFS
