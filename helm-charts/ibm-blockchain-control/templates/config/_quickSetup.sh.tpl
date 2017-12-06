#!/bin/bash

cd /shared

./script/createChannel.sh org1 TwoOrgsChannel channel1

./script/joinChannel.sh org1 channel1

./script/joinChannel.sh org2 channel1

git clone -b v1.0.3 https://github.com/hyperledger/fabric $GOPATH/src/github.com/hyperledger/fabric/

./script/installChaincode.sh org1 mycc v1 github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02/

./script/installChaincode.sh org2 mycc v1 github.com/hyperledger/fabric/examples/chaincode/go/chaincode_example02/

./script/instantiateChaincode.sh org1 mycc v1 channel1 "{\"Args\":[\"init\",\"a\",\"100\",\"b\",\"200\"]}"

