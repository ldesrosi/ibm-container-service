# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

---
################################################################################
#
#   Profile
#
#   - Different configuration profiles may be encoded here to be specified
#   as parameters to the configtxgen tool
#
################################################################################
Profiles:
    OrdererGenesis:
        Orderer:
            <<: *OrdererDefaults
            Organizations: 
            {{- range .Values.ordererOrganizations }}          
                - *{{ .name }} 
            {{- end }}
        Consortiums:
            {{ .Values.consortium.name }}:
                Organizations:
                {{- range .Values.peerOrganizations }}    
                    - *{{ .name }}
                {{- end }}      

################################################################################
#
#   Section: Organizations
#
#   - This section defines the different organizational identities which will
#   be referenced later in the configuration.
#
################################################################################
Organizations:

    # SampleOrg defines an MSP using the sampleconfig.  It should never be used
    # in production but may be used as a template for other definitions
    {{- range .Values.ordererOrganizations }}      
    - &{{ .name }}
        # DefaultOrg defines the organization which is used in the sampleconfig
        # of the fabric.git development environment
        Name: {{ .name }}

        # ID to load the MSP definition as
        ID: {{ .mspid }}

        # MSPDir is the filesystem path which contains the MSP configuration
        MSPDir: /data/ordererOrganizations/{{ .domain }}/msp

        # AdminPrincipal dictates the type of principal used for an organization's Admins policy
        # Today, only the values of Role.ADMIN ad Role.MEMBER are accepted, which indicates a principal
        # of role type ADMIN and role type MEMBER respectively
        AdminPrincipal: {{ .admin_principal }}  
    {{- end }}
        
    {{- range .Values.peerOrganizations }}

    - &{{ .name }}
        # DefaultOrg defines the organization which is used in the sampleconfig
        # of the fabric.git development environment
        Name: {{ .name }}

        # ID to load the MSP definition as
        ID: {{ .mspid }}

        MSPDir: /data/peerOrganizations/{{ .domain }}/msp/

        # AdminPrincipal dictates the type of principal used for an organization's Admins policy
        # Today, only the values of Role.ADMIN ad Role.MEMBER are accepted, which indicates a principal
        # of role type ADMIN and role type MEMBER respectively
        AdminPrincipal: {{ .admin_principal }}

        AnchorPeers:
            # AnchorPeers defines the location of peers which can be used
            # for cross org gossip communication.  Note, this value is only
            # encoded in the genesis block in the Application section context
            {{- range .nodes }}
            {{ if eq .peerType "anchor" }}
            - Host: {{ .service.name }}
              Port: {{ .service.externalPort }}
            {{- end }}
            {{- end }}
    {{- end }}

################################################################################
#
#   SECTION: Orderer
#
#   - This section defines the values to encode into a config transaction or
#   genesis block for orderer related parameters
#
################################################################################
Orderer: &OrdererDefaults

    # Orderer Type: The orderer implementation to start
    # Available types are "solo" and "kafka"
    OrdererType: {{ .Values.target.orderer.type }}

    Addresses:
        - {{ .Values.target.orderer.service.name }}:{{ .Values.target.orderer.service.externalPort }}

    # Batch Timeout: The amount of time to wait before creating a batch
    BatchTimeout: 2s

    # Batch Size: Controls the number of messages batched into a block
    BatchSize:

        # Max Message Count: The maximum number of messages to permit in a batch
        MaxMessageCount: 10

        # Absolute Max Bytes: The absolute maximum number of bytes allowed for
        # the serialized messages in a batch.
        AbsoluteMaxBytes: 98 MB

        # Preferred Max Bytes: The preferred maximum number of bytes allowed for
        # the serialized messages in a batch. A message larger than the preferred
        # max bytes will result in a batch larger than preferred max bytes.
        PreferredMaxBytes: 512 KB

    Kafka:
        # Brokers: A list of Kafka brokers to which the orderer connects
        # NOTE: Use IP:port notation
        Brokers:
            {{- range .Values.target.orderer.kafka.brokers }}
            - {{ .service.name }}:{{ .service.externalPort }}
            {{- end }}

    # Organizations is the list of orgs which are defined as participants on
    # the orderer side of the network
    Organizations:

################################################################################
#
#   SECTION: Application
#
#   - This section defines the values to encode into a config transaction or
#   genesis block for application related parameters
#
################################################################################
Application: &ApplicationDefaults

    # Organizations is the list of orgs which are defined as participants on
    # the application side of the network
    Organizations:
