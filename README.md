# Dolos - DoD PKI Testing Environment

Dolos provides a containerized environment for testing CAC authentication systems against a simulated DoD PKI infrastructure. It generates a complete certificate chain including root CAs, intermediate CAs, and client certificates that mirror the actual DoD PKI structure.

## Current Components

### Root Certificate Authorities
- **DoDRoot3** - RSA 2048 w/ SHA256 (Expires: Dec 30 2029)
- **DoDRoot4** - ECDSA w/ SHA256 using prime256v1 (Expires: Jul 25 2032) 
- **DoDRoot5** - ECDSA w/ SHA384 using secp384r1 (Expires: Jun 14 2041)

### Intermediate CAs (All signed by DoDRoot3)
- **DOD ID CA-59** (Expires: Apr 2 2025)
- **DOD ID CA-62** (Expires: Jun 1 2027)
- **DOD ID CA-63** (Expires: Apr 6 2027)
- **DOD ID CA-64** (Expires: Jun 1 2027)
- **DOD ID CA-65** (Expires: Jun 1 2027)

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
```
/opt/create_ca.sh
```

3. Create client certificates:
```
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

## Notes
The OCSP responder (docker-entrypoint.sh) can be configured for any CA by modifying the CA variable. Default configuration watches CA-59's index.txt for changes and provides real-time certificate status responses. Currently the Dockerfile has this option commented out.

## Screenshots

- <img width="358" alt="Screenshot 2025-01-23 at 7 19 25 AM" src="https://github.com/user-attachments/assets/2b06a730-cb08-4c9c-87c4-ffa27b406ebf" />

- <img width="307" alt="Screenshot 2025-01-23 at 7 17 05 AM" src="https://github.com/user-attachments/assets/dab6e664-b46d-41ec-9a20-92bd037c6ce3" />

- <img width="302" alt="Screenshot 2025-01-23 at 7 17 10 AM" src="https://github.com/user-attachments/assets/fc916cb4-43cd-4306-99ff-0d345795b985" />

- <img width="320" alt="Screenshot 2025-01-23 at 7 17 19 AM" src="https://github.com/user-attachments/assets/903f676b-e53a-4a32-a986-5d4d3d009c53" />

- <img width="441" alt="Screenshot 2025-01-23 at 7 17 26 AM" src="https://github.com/user-attachments/assets/df58928d-9ad9-4705-be30-c5b6a0bf7a5e" />

- <img width="468" alt="Screenshot 2025-01-23 at 7 17 34 AM" src="https://github.com/user-attachments/assets/029b5367-225d-4a23-9c8c-5e8aa2a35801" />

- <img width="308" alt="Screenshot 2025-01-23 at 7 17 41 AM" src="https://github.com/user-attachments/assets/4ee999df-0df0-43ef-9aa4-d1ccf43b8272" />

- <img width="313" alt="Screenshot 2025-01-23 at 7 17 48 AM" src="https://github.com/user-attachments/assets/a27da43b-e3b1-4c50-9196-53553cee591c" />

- <img width="555" alt="Screenshot 2025-01-23 at 7 17 55 AM" src="https://github.com/user-attachments/assets/821c347b-7289-4457-b0ff-e9f8f69dc7b5" />
