#!/bin/sh

if [ $# -ne 5 ];
  then
    echo "cardImport.sh <COMPOSER-PROFILE> <CARD_NAME> <CHANNEL_ADMIN> <ADMIN_CERT> <ADMIN_KEY>"
    exit 255
fi

PROFILE=$1
CARD=$2
ADMIN=$3
ADMIN_CERT=$4
ADMIN_KEY=$5

composer card create -f ${CARD}.card -p $PROFILE -u ${CARD} -r ${CARD} -r ${ADMIN} \
                     -c ${ADMIN_CERT} \
                     -k ${ADMIN_KEY}
composer card import -f ${CARD}.card

touch /shared/composer_ready