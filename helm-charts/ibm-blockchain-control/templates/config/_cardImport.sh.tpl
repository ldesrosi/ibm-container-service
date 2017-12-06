#!/bin/sh

if [ $# -ne 4 ];
  then
    echo "cardImport.sh <COMPOSER-PROFILE> <CARD_NAME> <CHANNEL_ADMIN> <DOMAIN>"
    exit 255
fi

PROFILE=$1
CARD=$2
ADMIN=$3
DOMAIN=$4
ADMIN_CERT=/shared/crypto-config/peerOrganizations/${DOMAIN}/users/Admin@${DOMAIN}/msp/signcerts/Admin@${DOMAIN}-cert.pem
ADMIN_KEY=/shared/crypto-config/peerOrganizations/${DOMAIN}/users/Admin@${DOMAIN}/msp/keystore/key.pem

cd /home/composer/.composer

composer card create -f ${CARD}.card -p $PROFILE -u ${CARD} -r ${CARD} -r ${ADMIN} \
                     -c ${ADMIN_CERT} \
                     -k ${ADMIN_KEY}
composer card import -f ${CARD}.card

touch /home/composer/.composer/composer_ready