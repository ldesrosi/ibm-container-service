FROM hyperledger/fabric-tools:x86_64-1.1.0

# Reset npm logging to default level.
ENV NPM_CONFIG_LOGLEVEL warn

# Install the latest version by default.
ARG VERSION=next

# Need to install extra dependencies for native modules.
RUN useradd --create-home --shell /bin/sh --uid 1000 composer && \
    adduser --gid 1000 composer composer && \
    apt-get install make gcc g++ python git libc6 && \
    su -c "npm config set prefix '/home/composer/.npm-global'" - composer && \
    su -c "npm install --production -g composer-cli@${VERSION}" - composer && \
    su -c "npm cache clean --force" - composer && \
    rm -rf /home/composer/.config /home/composer/.node-gyp /home/composer/.npm

COPY ./src/github.com/hyperledger/fabric-ca/bin/fabric-ca-client /usr/local/bin/fabric-ca-client
RUN chmod +x /usr/local/bin/fabric-ca-client
COPY ./src/github.com/hyperledger/fabric-ca/bin/fabric-ca-server /usr/local/bin/fabric-ca-server
RUN chmod +x /usr/local/bin/fabric-ca-server

RUN apt-get -y -qq update && apt-get install -y -qq curl && apt-get install -y redis-tools && apt-get clean
RUN curl -o /usr/local/bin/jq http://stedolan.github.io/jq/download/linux64/jq && chmod +x /usr/local/bin/jq
RUN curl -fsSL https://clis.ng.bluemix.net/install/linux | sh
RUN curl -Lo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod +x /usr/local/bin/kubectl
RUN wget https://releases.hashicorp.com/consul/1.0.6/consul_1.0.6_linux_amd64.zip && \
    unzip consul_1.0.6_linux_amd64.zip -d /usr/local/bin && \
    rm consul_1.0.6_linux_amd64.zip
    
# Add global composer modules to the path.
ENV PATH /home/composer/.npm-global/bin:$PATH