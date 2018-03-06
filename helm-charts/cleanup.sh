#/bin/bash

helm delete network-store network-ca org1-ca org2-ca network-orderer org1-peer org2-peer --purge
kubectl delete jobs mgmt-job-org1-peer mgmt-job-org2-peer