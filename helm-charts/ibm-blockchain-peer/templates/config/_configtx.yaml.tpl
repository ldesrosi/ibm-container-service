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
    
    {{- range .Values.consortium.channels }}
    {{ .name }}Channel:
        Consortium: {{ $.Values.consortium.name }}
        Application:
            <<: *ApplicationDefaults
            Organizations:
                {{- range .orgs }}
                - *{{ .name }}
                {{- end }}
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
        MSPDir: ordererOrganizations/{{ .domain }}/msp

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

        MSPDir: peerOrganizations/{{ .domain }}/msp/

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

