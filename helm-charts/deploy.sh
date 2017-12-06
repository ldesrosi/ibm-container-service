#/bin/bash

helm install --wait --timeout 300 --values=./overrides.yaml --name control  ibm-blockchain-control 
helm install --wait --timeout 300 --values=./overrides.yaml --name ca       ibm-blockchain-ca
helm install --wait --timeout 300 --values=./overrides.yaml --name orderer  ibm-blockchain-orderer
helm install --wait --timeout 300 --values=./overrides.yaml --name peer     ibm-blockchain-peer
helm install --wait --timeout 300 --values=./overrides.yaml --name composer ibm-blockchain-composer