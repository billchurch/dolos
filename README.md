# Dolos - DoD PKI Testing Environment

![dolos](images/dolos.png)
Dolos provides a containerized environment for testing CAC authentication systems against a simulated DoD PKI infrastructure. It generates a complete certificate chain including root CAs, intermediate CAs, and client certificates that mimmics the actual DoD PKI structure for testing purposes.

Note: This is a work in progress and the key-sizes may not represent the actual DoD PKI key sizes.

## Current Components

### Root Certificate Authorities

- **DoDRoot6** - RSA 2048 w/ SHA384 (Expires: Jan 24 2053)
- **DoDRoot5** - ECDSA w/ SHA384 using secp384r1 (Expires: Jun 14 2041)
- **DoDRoot4** - ECDSA w/ SHA256 using prime256v1 (Expires: Jul 25 2032)
- **DoDRoot3** - RSA 2048 w/ SHA256 (Expires: Dec 30 2029)

### Intermediate CAs

#### Signed by DoDRoot3

- **DOD ID CA-59** (Expires: Apr 2 2025)
- **DOD ID CA-62** (Expires: Jun 1 2027)
- **DOD ID CA-63** (Expires: Apr 6 2027)
- **DOD ID CA-64** (Expires: Jun 1 2027)
- **DOD ID CA-65** (Expires: Jun 1 2027)

#### Signed by DoDRoot6

- **DOD ID CA-70** (Expires: May 16 2029)
- **DOD ID CA-71** (Expires: Dec 6 2028)
- **DOD ID CA-72** (Expires: May 16 2029)
- **DOD ID CA-73** (Expires: May 16 2029)

### PKI Heirarchy

```mermaid
graph TD
    R6[DoD Root CA 6<br/>RSA 2048]
    R5[DoD Root CA 5<br/>ECC P-384]
    R4[DoD Root CA 4<br/>ECC P-256]
    R3[DoD Root CA 3<br/>RSA 2048]
    
    I59[DoD ID CA-59<br/>RSA 2048]
    I62[DoD ID CA-62<br/>RSA 2048]
    I63[DoD ID CA-63<br/>RSA 2048]
    I64[DoD ID CA-64<br/>RSA 2048]
    I65[DoD ID CA-65<br/>RSA 2048]
    I70[DoD ID CA-70<br/>RSA 2048]
    I71[DoD ID CA-71<br/>RSA 2048]
    I72[DoD ID CA-72<br/>RSA 2048]
    I73[DoD ID CA-73<br/>RSA 2048]

    R3 --> I59
    R3 --> I62
    R3 --> I63 
    R3 --> I64
    R3 --> I65
    R6 --> I70
    R6 --> I71
    R6 --> I72
    R6 --> I73

```

### Services

- **OCSP Responder** - Running on port 2560, defaults to CA-59 but configurable
- **Certificate Generation** - Interactive client certificate creation with customizable parameters

## Directory Structure

The `create_ca.sh` script generates a comprehensive PKI structure under `/app`:

- Individual CA directories (CA-59 through CA-65)
- Root certificates in `/app/certs`
- CRLs in `/app/crl`
- Private keys in `/app/private`
- OCSP certificates and keys for each CA

## Usage

1. Start the container:

    ```bash
    docker run --rm -it \
      --mount type=bind,source=$(pwd)/root,target=/opt \
      --mount type=bind,source=$(pwd)/app,target=/app \
      --name ocsp -p 2560:2560 ocsp /bin/bash
    ```

2. Generate PKI infrastructure:

    ```bash
    /opt/create_ca.sh
    ```

3. Create client certificates:

    ```bash
    /opt/create_client.sh
    ```

## Planned Features

- LDAP/Active Directory integration for certificate authorization
- CRL Distribution Point (CRLDP) implementation
- Web interface for certificate management
- Automated testing tools for CAC authentication
- Support for additional DoD certificate profiles
- Docker Compose setup for multi-service deployment

## References

- CAC Next Generation Implementation Guide v2.6
- DoD PKI Transitional Implementation Guide
- Various DoD certificate specifications and standards
- <https://crl.gds.disa.mil/>

## Notes

The OCSP responder (docker-entrypoint.sh) can be configured for any CA by modifying the CA variable. Default configuration watches CA-59's index.txt for changes and provides real-time certificate status responses. Currently the Dockerfile has this option commented out.

## Screenshots

Creating the CAs:
![alt text](<images/screenshots/Screenshot 2025-01-23 at 7.19.25 AM.png>)

Name:
![Entering Name for Certificate](<images/screenshots/Screenshot 2025-01-23 at 7.17.05 AM.png>)

EDIPI:
![EDIPI](<images/screenshots/Screenshot 2025-01-23 at 7.17.10 AM.png>)

Org Category:
![Org Category](<images/screenshots/Screenshot 2025-01-23 at 7.17.19 AM.png>)

Agency Code:
![Agency Code](<images/screenshots/Screenshot 2025-01-23 at 7.17.26 AM.png>)

Person/Org Category:
![Person/Org Category](<images/screenshots/Screenshot 2025-01-23 at 7.17.34 AM.png>)

Cert Lifetime:
![Cert Lifetime](<images/screenshots/Screenshot 2025-01-23 at 7.17.41 AM.png>)

Selecting the Signing CA:
![Selecting the Signing CA](<images/screenshots/Screenshot 2025-01-23 at 7.17.48 AM.png>)

Certificate Generated:
![Certificate Generated](<images/screenshots/Screenshot 2025-01-23 at 7.17.55 AM.png>)
