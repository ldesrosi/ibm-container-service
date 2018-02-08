#!/bin/sh

if [ $# -ne 2 ]
  then
    echo "No arguments supplied; Expected <URL> <HTTP STATUS CODE>"
    exit -1
fi

URL=$1
EXPECTED_STATUS=$2

printf "Waiting for ${URL} to be available.\n"
while true ; do
   STATUS="$(curl -s -w %{http_code} -o /dev/null --connect-timeout 2 ${URL} )"
   if [ "${STATUS}" = "${EXPECTED_STATUS}" ]; then
       printf "Service is up and running.\n"
       printf "Proceeding with deployment.\n"
       break
   else
       sleep 2
       printf "."
   fi
done