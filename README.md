# Infroduction
Dolos is a collection of containers to support testing a system or service for authenticating with a Common Access Card (CAC) against an infrastructure representative of a typical DoD authentication environment

# Components
## Certificate Authorities
### DoDRoot3
Modeled after DoD Root CA 3, RSA 2048 w/ SHA256 which is set to expire in the real-world on 20291230

### DoDRoot4
Modeled after DoD Root CA 4, ecdsa-with-SHA256 prime256v1, which is set to expire in the real-world on 20320625

### DoDRoot5
Modeled after DoD Root CA 5, ecdsa-with-SHA384 secp384r1, which is set to expire in the real-world on 20410614

## Subordinate CAs
### DOD ID CA-59
Modled after DOD ID CA-59 and signed by DoDRoot3 RSA 2048 w/ SHA256, set to expire in the real-world on 20250402

Several subordinate CAs are created to represent a larger bundle of certificates that would likely need to be loaded on a system
## CRLDP
A large CRL is provided in the CRLDP to represent the large CRLs present in the DOD 
## OCSP Server
An OCSP server to check for real-time certificate revocation
## LDAP Server
An LDAP server to provide authorization data for related certificates. Note this is usually a Microsoft Active Directory, but OpenLDAP is used for simplicity here

# Instructions
docker run --rm -it --mount type=bind,source=$(pwd)/root,target=/opt --mount type=bind,source=$(pwd)/app,target=/app --name oscp -p 2560:2560 oscp /bin/bash
`/opt/create_ca.sh`
`/opt/create_client.sh`
# Notes
https://www.cac.mil/Portals/53/Documents/CAC_NG_Implementation_Guide_v2.6.pdf
https://devblogs.microsoft.com/scripting/building-a-demo-active-directory-part-1/
