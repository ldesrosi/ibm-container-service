curl -L -o network.bna
curl -L  -o endorsement.json

composer network start -c PeerAdmin@fabric-network -a tutorial-network.bna -A admin -S adminpw

composer card import -f admin@tutorial-network.card