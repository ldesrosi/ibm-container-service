FROM hyperledger/fabric-tools:x86_64-1.1.0-alpha

COPY ./src/github.com/hyperledger/fabric-ca/bin/fabric-ca-client /usr/local/bin/fabric-ca-client
RUN chmod +x /usr/local/bin/fabric-ca-client

RUN apt-get -y -qq update && apt-get install -y -qq curl && apt-get clean
RUN curl -o /usr/local/bin/jq http://stedolan.github.io/jq/download/linux64/jq && chmod +x /usr/local/bin/jq
RUN curl -fsSL https://clis.ng.bluemix.net/install/linux | sh