#!/bin/sh

if [ $# -eq 0 ]
  then
    echo "No arguments supplied; Expected configtx profile name"
    exit -1
fi

PROFILE=$1
export FABRIC_CFG_PATH=/shared

# We first ensure that the volume is clean from previous installs
rm -rf /shared/*
rm -rf /home/composer/.composer/*

#Ensure all scripts are executable
chmod +x /blockchain-config/*.sh

# Move files from bootstrap volumes to preserve them
cp /blockchain-config/crypto-config.yaml /shared
cp /blockchain-config/configtx.yaml /shared

#Move certificate authority configuration files
mkdir /shared/cas
cp /blockchain-config/ca.yaml /shared/cas
for filename in /blockchain-config/*-ca.yaml; do
  name=${filename##*/}
  subca_dir=${name%-ca.yaml}

  mkdir /shared/cas/$subca_dir
  cp $filename /shared/cas/$subca_dir/ca.yaml
done

#Setup scripts in the shared folder
mkdir /shared/script/
cp /blockchain-config/createChannel.sh /shared/script
cp /blockchain-config/joinChannel.sh /shared/script
cp /blockchain-config/installChaincode.sh /shared/script
cp /blockchain-config/instantiateChaincode.sh /shared/script
cp /blockchain-config/cardImport.sh /shared/script
cp /blockchain-config/quickSetup.sh /shared/script

# Move environment config file to the correct folder
mkdir /shared/env/
cp /blockchain-config/*-env.sh /shared/env

# Setup the composer connection profile
cp /blockchain-config/*-profile.json /shared

cd /shared

# Setup cryptogen base key and certificates
echo "Starting cryptogen" 
cryptogen generate --config /shared/crypto-config.yaml 

for file in $(find /shared/ -iname *_sk); 
do 
   dir=$(dirname $file); 
   mv ${dir}/*_sk ${dir}/key.pem; 
done 

find /shared -type d | xargs chmod a+rx
find /shared -type f | xargs chmod a+r 

# Setup genesis block
echo "Starting configtxgen" 
configtxgen -profile $PROFILE -outputBlock orderer.block 

find /shared -type d | xargs chmod a+rx
find /shared -type f | xargs chmod a+r

echo "Done with bootstrapping"
touch /shared/bootstrapped 

