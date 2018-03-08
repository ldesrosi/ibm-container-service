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
            Capabilities:
                <<: *OrdererCapabilities
        Consortiums:
            {{ .Values.consortium.name }}:
                Organizations:
                {{- range .Values.peerOrganizations }}    
                    - *{{ .name }}
                {{- end }}      
    
    {{- range .Values.consortium.channels }}
    {{ .name }}Channel:
        Consortium: {{ $.Values.consortium.name }}
        Application:
            <<: *ApplicationDefaults
            Organizations:
                {{- range .orgs }}
                - *{{ .name }}
                {{- end }}
            Capabilities:
                <<: *ApplicationCapabilities
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
        Name: {{ .mspid }}

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
        Name: {{ .mspid }}

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
              Port: {{ .service.internalPort }}
            {{- end }}
            {{- end }}
    {{- end }}

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

################################################################################
#
#   SECTION: Capabilities
#
#   - This section defines the capabilities of fabric network. This is a new
#   concept as of v1.1.0 and should not be utilized in mixed networks with
#   v1.0.x peers and orderers.  Capabilities define features which must be
#   present in a fabric binary for that binary to safely participate in the
#   fabric network.  For instance, if a new MSP type is added, newer binaries
#   might recognize and validate the signatures from this type, while older
#   binaries without this support would be unable to validate those
#   transactions.  This could lead to different versions of the fabric binaries
#   having different world states.  Instead, defining a capability for a channel
#   informs those binaries without this capability that they must cease
#   processing transactions until they have been upgraded.  For v1.0.x if any
#   capabilities are defined (including a map with all capabilities turned off)
#   then the v1.0.x peer will deliberately crash.
#
################################################################################
Capabilities:
    # Channel capabilities apply to both the orderers and the peers and must be
    # supported by both.  Set the value of the capability to true to require it.
    Global: &ChannelCapabilities
        # V1.1 for Global is a catchall flag for behavior which has been
        # determined to be desired for all orderers and peers running v1.0.x,
        # but the modification of which would cause incompatibilities.  Users
        # should leave this flag set to true.
        V1_1: true

    # Orderer capabilities apply only to the orderers, and may be safely
    # manipulated without concern for upgrading peers.  Set the value of the
    # capability to true to require it.
    Orderer: &OrdererCapabilities
        # V1.1 for Order is a catchall flag for behavior which has been
        # determined to be desired for all orderers running v1.0.x, but the
        # modification of which  would cause incompatibilities.  Users should
        # leave this flag set to true.
        V1_1: true

    # Application capabilities apply only to the peer network, and may be safely
    # manipulated without concern for upgrading orderers.  Set the value of the
    # capability to true to require it.
    Application: &ApplicationCapabilities
        # V1.1 for Application is a catchall flag for behavior which has been
        # determined to be desired for all peers running v1.0.x, but the
        # modification of which would cause incompatibilities.  Users should
        # leave this flag set to true.
        V1_1: true

