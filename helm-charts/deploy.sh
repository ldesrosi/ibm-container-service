#/bin/bash

helm upgrade --install --values=./config/orderer/ca.yaml network-ca ibm-blockchain-ca
sleep 60
helm upgrade --install --values=./config/org1/ca.yaml org1-ca ibm-blockchain-ca
helm upgrade --install --values=./config/org2/ca.yaml org2-ca ibm-blockchain-ca
sleep 60
helm upgrade --install --values=./config/orderer/orderer.yaml network-orderer ibm-blockchain-orderer
sleep 30
helm upgrade --install --values=./config/org1/peer.yaml --set generateGenesisBlock=true org1-peer ibm-blockchain-peer
helm upgrade --install --values=./config/org2/peer.yaml org2-peer ibm-blockchain-peer