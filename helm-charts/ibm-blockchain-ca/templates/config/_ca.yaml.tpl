#############################################################################
#   This is a configuration file for the fabric-ca-server command.
#
#   COMMAND LINE ARGUMENTS AND ENVIRONMENT VARIABLES
#   ------------------------------------------------
#   Each configuration element can be overridden via command line
#   arguments or environment variables.  The precedence for determining
#   the value of each element is as follows:
#   1) command line argument
#      Examples:
#      a) --port 443
#         To set the listening port
#      b) --ca-keyfile ../mykey.pem
#         To set the "keyfile" element in the "ca" section below;
#         note the '-' separator character.
#   2) environment variable
#      Examples:
#      a) FABRIC_CA_SERVER_PORT=443
#         To set the listening port
#      b) FABRIC_CA_SERVER_CA_KEYFILE="../mykey.pem"
#         To set the "keyfile" element in the "ca" section below;
#         note the '_' separator character.
#   3) configuration file
#   4) default value (if there is one)
#      All default values are shown beside each element below.
#
#   FILE NAME ELEMENTS
#   ------------------
#   All filename elements below end with the word "file".
#   For example, see "certfile" and "keyfile" in the "ca" section.
#   The value of each filename element can be a simple filename, a
#   relative path, or an absolute path.  If the value is not an
#   absolute path, it is interpretted as being relative to the location
#   of this configuration file.
#
#############################################################################

{{ if .service }}
# Server's listening port (default: 7054)
port: {{ .service.internalPort }}
{{ end }}

# Enables debug logging (default: false)
debug: false

# Size limit of an acceptable CRL in bytes (default: 512000)
crlsizelimit: 512000

#############################################################################
#  TLS section for the server's listening port
#
#  The following types are supported for client authentication: NoClientCert,
#  RequestClientCert, RequireAnyClientCert, VerifyClientCertIfGiven,
#  and RequireAndVerifyClientCert.
#
#  Certfiles is a list of root certificate authorities that the server uses
#  when verifying client certificates.
#############################################################################
tls:
  # Enable TLS (default: false)
  enabled: false
  # TLS for the server's listening port
  certfile: /data/cas/msp/tls/tls-cert.pem
  keyfile:
  clientauth:
    type: noclientcert
    certfiles:

#############################################################################
#  The CA section contains information related to the Certificate Authority
#  including the name of the CA, which should be unique for all members
#  of a blockchain network.  It also includes the key and certificate files
#  used when issuing enrollment certificates (ECerts) and transaction
#  certificates (TCerts).
#  The chainfile (if it exists) contains the certificate chain which
#  should be trusted for this CA, where the 1st in the chain is always the
#  root CA certificate.
#############################################################################
ca:
  # Name of this CA
  name: {{ .name }}
  # Key file (default: ca-key.pem)
  keyfile: /data/cas/msp/keystore/key.pem
  # Certificate file (default: ca-cert.pem)
  certfile: /data/cas/msp/signcerts/ca.{{ .domain }}-cert.pem
  # Chain file (default: chain-cert.pem)
  #chainfile: ca-chain.pem
  chainfile: /data/cas/msp/cacerts/ca.{{ .domain }}-chain.pem

#############################################################################
#  The gencrl REST endpoint is used to generate a CRL that contains revoked
#  certificates. This section contains configuration options that are used
#  during gencrl request processing.
#############################################################################
crl:
  # Specifies expiration for the generated CRL. The number of hours
  # specified by this property is added to the UTC time, the resulting time
  # is used to set the 'Next Update' date of the CRL.
  expiry: 24h
  
#############################################################################
#  The registry section controls how the fabric-ca-server does two things:
#  1) authenticates enrollment requests which contain a username and password
#     (also known as an enrollment ID and secret).
#  2) once authenticated, retrieves the identity's attribute names and
#     values which the fabric-ca-server optionally puts into TCerts
#     which it issues for transacting on the Hyperledger Fabric blockchain.
#     These attributes are useful for making access control decisions in
#     chaincode.
#  There are two main configuration options:
#  1) The fabric-ca-server is the registry
#  2) An LDAP server is the registry, in which case the fabric-ca-server
#     calls the LDAP server to perform these tasks.
#############################################################################
registry:
  # Maximum number of times a password/secret can be reused for enrollment
  # (default: 0, which means there is no limit)
  maxEnrollments: -1

  # Contains identity information which is used when LDAP is disabled
  identities:
     - name: {{ .admin }}
       pass: {{ .password }}
       type: client
       affiliation: ""
       attrs:
          hf.Registrar.Roles: "{{ .registrar.roles }}"
          hf.Registrar.DelegateRoles: "{{ .registrar.delegatedRoles }}"
          hf.Revoker: {{ .registrar.revoker }}
          hf.IntermediateCA: {{ .registrar.intermediateCA }}
          hf.GenCRL: {{ .registrar.genCRL }}
          hf.Registrar.Attributes: "{{ .registrar.attributes }}"

#############################################################################
#  Database section
#  Supported types are: "sqlite3", "postgres", and "mysql".
#  The datasource value depends on the type.
#  If the type is "sqlite3", the datasource value is a file name to use
#  as the database store.  Since "sqlite3" is an embedded database, it
#  may not be used if you want to run the fabric-ca-server in a cluster.
#  To run the fabric-ca-server in a cluster, you must choose "postgres"
#  or "mysql".
#############################################################################
db:
  type: sqlite3
  datasource: /data/fabric-ca-server.db
  tls:
      enabled: false
      certfiles:
        - db-server-cert.pem
      client:
        certfile: db-client-cert.pem
        keyfile: db-client-key.pem

#############################################################################
#  LDAP section
#  If LDAP is enabled, the fabric-ca-server calls LDAP to:
#  1) authenticate enrollment ID and secret (i.e. username and password)
#     for enrollment requests;
#  2) To retrieve identity attributes
#############################################################################
ldap:
   # Enables or disables the LDAP client (default: false)
   enabled: false
   # The URL of the LDAP server
   url: ldap://<adminDN>:<adminPassword>@<host>:<port>/<base>
   tls:
      certfiles:
        - ldap-server-cert.pem
      client:
         certfile: ldap-client-cert.pem
         keyfile: ldap-client-key.pem

#############################################################################
#  Affiliation section
#############################################################################
affiliations:
  {{- range .affiliations }}
  {{ .name | lower }}:
  {{- range .departments }}
    - {{ . }}
  {{- end }}
  {{- end }}


#############################################################################
#  Signing section
#
#  The "default" subsection is used to sign enrollment certificates;
#  the default expiration ("expiry" field) is "8760h", which is 1 year in hours.
#
#  The "ca" profile subsection is used to sign intermediate CA certificates;
#  the default expiration ("expiry" field) is "43800h" which is 5 years in hours.
#  Note that "isca" is true, meaning that it issues a CA certificate.
#  A maxpathlen of 0 means that the intermediate CA cannot issue other
#  intermediate CA certificates, though it can still issue end entity certificates.
#  (See RFC 5280, section 4.2.1.9)
#
#  The "tls" profile subsection is used to sign TLS certificate requests;
#  the default expiration ("expiry" field) is "8760h", which is 1 year in hours.
#############################################################################
signing:
    default:
      usage:
        - digital signature
      expiry: 8760h
    profiles:
      ca:
         usage:
           - cert sign
           - crl sign
         expiry: 43800h
         caconstraint:
            isca: true
            {{ if and .root false }}
            maxpathlen: 1
            {{- else -}}
            maxpathlen: 0
            {{- end }}
      tls:
         usage:
            - signing
            - key encipherment
            - server auth
            - client auth
            - key agreement
         expiry: 8760h

###########################################################################
#  Certificate Signing Request (CSR) section.
#  This controls the creation of the root CA certificate.
#  The expiration for the root CA certificate is configured with the
#  "ca.expiry" field below, whose default value is "131400h" which is
#  15 years in hours.
#  The pathlength field is used to limit CA certificate hierarchy as described
#  in section 4.2.1.9 of RFC 5280.
#  Examples:
#  1) No pathlength value means no limit is requested.
#  2) pathlength == 1 means a limit of 1 is requested which is the default for
#     a root CA.  This means the root CA can issue intermediate CA certificates,
#     but these intermediate CAs may not in turn issue other CA certificates
#     though they can still issue end entity certificates.
#  3) pathlength == 0 means a limit of 0 is requested;
#     this is the default for an intermediate CA, which means it can not issue
#     CA certificates though it can still issue end entity certificates.
###########################################################################
csr:
{{ if and .root false }}
    cn: {{ .name | lower }}
{{ end }}
    names:
    {{- range .DNs }}
      - C: {{ .C }}
        ST: {{ .ST }}
        L: {{ .L }}
        O: {{ .O }}
        OU: {{ .OU }}
    {{- end }}
    hosts:
     - {{ .name | lower }}.{{ .domain }}
     - localhost
    ca:
      expiry: 131400h
      {{ if and .root false }}
      pathlength: 1
      {{- end }}
#############################################################################
# BCCSP (BlockChain Crypto Service Provider) section is used to select which
# crypto library implementation to use
#############################################################################
bccsp:
    default: SW
    sw:
        hash: SHA2
        security: 256
        filekeystore:
            # The directory used for the software file-based keystore
            keystore: /data/cas/msp/keystore

#############################################################################
# The fabric-ca-server init and start commands support the following two
# additional mutually exclusive options:
#
# 1) --cacount <number-of-CAs>
# Automatically generate multiple default CA instances.
# This is particularly useful in a development environment to quickly set up
# multiple CAs.
# For example,
#     fabric-ca-server start -b admin:adminpw --cacount 2
# starts a server with a default CA and two non-default CA's with names
# 'ca1' and 'ca2'.
#
# 2) --cafiles <CA-config-files>
# For each CA config file in the list, generate a separate signing CA.  Each CA
# config file in this list MAY contain all of the same elements as are found in
# the server config file except port, debug, and tls sections.
# For example,
#    fabric-ca-server start -b admin:adminpw                \
#          --cafiles ca/ca1/fabric-ca-server-config.yaml    \
#          --cafiles ca/ca2/fabric-ca-server-config.yaml
# is equivalent to the previous example, except the files CA config files
# must already exist and can be customized.
#
#############################################################################

cacount:

cafiles:
  {{- range $index, $org := .sub_cas }}
  - /data/cas/{{ .name | lower }}/ca.yaml
  {{- end }}
#############################################################################
# Intermediate CA section
#
# The relationship between servers and CAs is as follows:
#   1) A single server process may contain or function as one or more CAs.
#      This is configured by the "Multi CA section" above.
#   2) Each CA is either a root CA or an intermediate CA.
#   3) Each intermediate CA has a parent CA which is either a root CA or another intermediate CA.
#
# This section pertains to configuration of #2 and #3.
# If the "intermediate.parentserver.url" property is set,
# then this is an intermediate CA with the specified parent
# CA.
#
# parentserver section
#    url - The URL of the parent server
#    caname - Name of the CA to enroll within the server
#
# enrollment section used to enroll intermediate CA with parent CA
#    profile - Name of the signing profile to use in issuing the certificate
#    label - Label to use in HSM operations
#
# tls section for secure socket connection
#   certfiles - PEM-encoded list of trusted root certificate files
#   client:
#     certfile - PEM-encoded certificate file for when client authentication
#     is enabled on server
#     keyfile - PEM-encoded key file for when client authentication
#     is enabled on server
#############################################################################
intermediate:
  parentserver:
    url:
    caname:

  enrollment:
    hosts:
    profile:
    label:

  tls:
    certfiles:
    client:
      certfile:
      keyfile: