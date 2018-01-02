#/bin/bash

helm upgrade --install --values=./config/orderer/ca.yaml --reuse-values network-ca ibm-blockchain-ca

helm upgrade --install --values=./config/org1/ca.yaml --reuse-values org1-ca ibm-blockchain-ca
