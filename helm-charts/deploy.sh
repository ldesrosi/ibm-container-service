#/bin/bash

helm install --values=./overrides.yaml --name config ibm-blockchain-control
sleep 10
helm install --values=./overrides.yaml --name ca ibm-blockchain-ca
sleep 10
helm install  --values=./overrides.yaml --name orderer ibm-blockchain-orderer
sleep 10
helm install  --values=./overrides.yaml --name peer ibm-blockchain-peer
sleep 10
helm install  --values=./overrides.yaml --name peer ibm-blockchain-composer