#/bin/bash

helm install --wait --timeout 300 --values=./overrides.yaml --name control  ibm-blockchain-control 
helm install --wait --timeout 300 --values=./overrides.yaml --name ca       ibm-blockchain-ca
helm install --wait --timeout 300 --values=./overrides.yaml --name orderer  ibm-blockchain-orderer
helm install --wait --timeout 300 --values=./overrides.yaml --name peer     ibm-blockchain-peer
helm install --wait --timeout 300 --values=./overrides.yaml --name composer ibm-blockchain-composer

export CONTROL=$(kubectl get po -l name=blockchain-control  -o 'jsonpath={.items[0].metadata.name}')

sleep 60

kubectl exec -ti ${CONTROL} -c cli -- /shared/script/quickSetup.sh
kubectl exec -ti ${CONTROL} -c composer -- /shared/script/cardImport.sh /shared/org1-profile.json PeerAdmin ChannelAdmin org1.example.com