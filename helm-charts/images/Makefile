BASE_NAME			= fabric-tools
NAME				= $(BASE_NAME)-with-ca
TAGS				= x86_64-1.1.0
BASE_DOCKER_IMAGE	= $(BASE_NAME):$(TAGS)
BASE_REGISTRY		= hyperledger
CUSTOM_DOCKER_IMAGE = $(NAME):$(TAGS)
CUSTOM_REGISTRY		= ldesrosi

ROOT_DIR=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# COMMAND DEFINITIONS
BUILD		= docker build -t
RUN			= docker run 
LOGIN		= docker login
PUSH		= docker push
TAG			= docker tag

.PHONY: all
all: build build_docker push

.PHONY: build
build:
	echo ">> Building client within Docker container"
	$(RUN) --rm -v  "$(ROOT_DIR)":/go -w /go $(BASE_REGISTRY)/$(BASE_DOCKER_IMAGE) make build_client

.PHONY: build_client
build_client: clean
	echo ">> building fabric-ca-client binary"
	mkdir -p $(ROOT_DIR)/src/
	mkdir -p $(ROOT_DIR)/src/github.com/
	mkdir -p $(ROOT_DIR)/src/github.com/hyperledger/
	git clone https://github.com/hyperledger/fabric-ca.git --branch v1.1.0 $(ROOT_DIR)/src/github.com/hyperledger/fabric-ca
	export GOPATH="$(ROOT_DIR)"; make -C $(ROOT_DIR)/src/github.com/hyperledger/fabric-ca fabric-ca-client
	export GOPATH="$(ROOT_DIR)"; make -C $(ROOT_DIR)/src/github.com/hyperledger/fabric-ca fabric-ca-server

.PHONY: build_docker
build_docker: Dockerfile
	echo ">> building custom fabric-tools as $(CUSTOM_DOCKER_IMAGE)"
	$(BUILD) $(CUSTOM_DOCKER_IMAGE) .

.PHONY: push
push:
	echo ">> pushing release $(RELEASE) image to docker hub as $(CUSTOM_DOCKER_IMAGE)"
ifndef DOCKER_USERNAME
	$(LOGIN)
else
	$(LOGIN) -u="$(DOCKER_USERNAME)" -p="$(DOCKER_PASSWORD)"
endif
	$(TAG) $(CUSTOM_DOCKER_IMAGE) $(CUSTOM_REGISTRY)/$(CUSTOM_DOCKER_IMAGE)
	$(PUSH) $(CUSTOM_REGISTRY)/$(CUSTOM_DOCKER_IMAGE)

.PHONY: clean
clean: 
	echo ">> cleaning src directory"
	rm -rf $(ROOT_DIR)/src
