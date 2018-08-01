#!/bin/sh

if [ $# -ne 3 ]
  then
    echo "No arguments supplied; Expected <PROTOCOL> <URL> <EXPECTED CODE>"
    exit 255
fi

PROTOCOL=$1
URL=$2
EXPECTED_STATUS=$3

printf "Waiting for ${URL} to be available.\n"
while true ; do
   if [ "${PROTOCOL}" = "grpc" ]; then
      curl -s -o /dev/null --connect-timeout 2 ${URL}
      STATUS=$?
   elif [ "${PROTOCOL}" = "http" ] || [ "${PROTOCOL}" = "https" ]; then  
     STATUS="$(curl -s -w %{http_code} -o /dev/null --connect-timeout 2 ${URL} )"
     echo "Status is: ${STATUS} and return code is " $?
   else
     echo "Unknown protocol ${PROTOCOL}. Terminating."
     exit 255
   fi
   echo "Status ${STATUS} Expected Status ${EXPECTED_STATUS}"

   if [ "${STATUS}" = "${EXPECTED_STATUS}" ]; then
     printf "\nService is up and running.\n"
     printf "Proceeding with deployment.\n"
     exit 0
   else
     sleep 2
     printf "."
   fi
done