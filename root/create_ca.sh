#!/bin/bash
set -aeu

# setup CA directories
ROOT=/app
ROOT_CA_DIR=${ROOT}  # Base directory for root CA operations
crlDistributionPoints=""
authorityInfoAccess=""
NAME=""
EDIPI=""
AGENCY=""
UPN=""
SUBJ=""
CN="/C=US/O=U.S. Government/OU=DoD/OU=PKI/OU=USAF/CN="
URN=""
CERTSERIAL=""
FASCN=""
NATIONALITY=""

mkdir -p $ROOT/certs $ROOT/crl $ROOT/newcerts $ROOT/private $ROOT/csr
# Generate random data with spinner and success message
gum spin --spinner dot --title "Generating random seed..." -- dd if=/dev/urandom of=/app/private/.rand bs=256 count=1 2>/dev/null

# Show completion status
gum style --foreground 82 "✓ Random seed generated successfully"

cd $ROOT

#Read and write to root in private folder
chmod 700 private
chmod 600 private/.rand

touch $ROOT/index.txt
#Echo the user id
echo 1000 > $ROOT/serial

# Generates a Certificate Authority (CA) certificate and private key for the DoD Root CA.

# The function performs the following steps:
# 1. Generates a private key for the CA using the specified algorithm and curve.
# 2. Sets the private key file permissions to read-only for the running user.
# 3. Generates an X.509 self-signed certificate for the CA using the private key, with the specified validity period, signature algorithm, and extensions.
# 4. Saves the generated certificate to a file.
# 5. Sets the certificate file permissions to read-only for everyone.
function make_ca () {
      # Header for this root CA
      gum style \
        --border normal \
        --border-foreground 212 \
        --padding "0 1" \
        --align center \
        "Creating Root CA $CA"

      # Generate key with status
      if openssl $ALGO -out $ROOT/private/DoDRoot$CA.key.pem $CURVE > /dev/null 2>&1; then
          gum style --foreground 82 "✓ Generated DoDRoot$CA key"
          chmod 400 $ROOT/private/DoDRoot$CA.key.pem > /dev/null 2>&1
      else
          gum style --foreground 196 "✗ Failed to generate DoDRoot$CA key"
          exit 1
      fi

      # Generate certificate with status
      if faketime "$FAKETIME" openssl req -config /opt/ca.conf \
            -key $ROOT/private/DoDRoot$CA.key.pem \
            -new -x509 -days $DAYS -sha$SHA -extensions v3_ca \
            -out $ROOT/certs/DoDRoot$CA.cert.pem \
            -set_serial $SERIAL $EXTRAS \
            -subj "/C=US/O=U.S. Government/OU=DoD/OU=PKI/CN=DoD Root CA $CA" > /dev/null 2>&1; then
          gum style --foreground 82 "✓ Created DoDRoot$CA certificate"
          chmod 444 $ROOT/certs/DoDRoot$CA.cert.pem > /dev/null 2>&1
      else
          gum style --foreground 196 "✗ Failed to create DoDRoot$CA certificate"
          exit 1
      fi
}


# Original DoDRoot5.cer 
# Certificate:
#     Data:
#         Version: 3 (0x2)
#         Serial Number: 15 (0xf)
#         Signature Algorithm: ecdsa-with-SHA384
#         Issuer: C = US, O = U.S. Government, OU = DoD, OU = PKI, CN = DoD Root CA 5
#         Validity
#             Not Before: Jun 14 17:17:27 2016 GMT
#             Not After : Jun 14 17:17:27 2041 GMT
#         Subject: C = US, O = U.S. Government, OU = DoD, OU = PKI, CN = DoD Root CA 5
#         Subject Public Key Info:
#             Public Key Algorithm: id-ecPublicKey
#                 Public-Key: (384 bit)
#                 pub:
#                     ...
#                 ASN1 OID: secp384r1
#                 NIST CURVE: P-384
#         X509v3 extensions:
#             X509v3 Subject Key Identifier: 
#                 86:C0:15:42:FB:71:76:DC:3E:2D:11:5B:21:10:44:35:CA:C1:DC:14
#             X509v3 Key Usage: critical
#                 Certificate Sign, CRL Sign
#             X509v3 Basic Constraints: critical
#                 CA:TRUE
#     Signature Algorithm: ecdsa-with-SHA384
CA=5
SERIAL=15
DAYS=9130
FAKETIME='2016-06-14 12:17:27'
ALGO="ecparam"
CURVE="-name secp384r1 -genkey"
SHA=384 
EXTRAS="-addext keyUsage=keyCertSign,cRLSign -addext basicConstraints=critical,CA:true"

make_ca

# Oriignal DoDRoot4.cer 
# Certificate:
#     Data:
#         Version: 3 (0x2)
#         Serial Number: 1 (0x1)
#         Signature Algorithm: ecdsa-with-SHA256
#         Issuer: C = US, O = U.S. Government, OU = DoD, OU = PKI, CN = DoD Root CA 4
#         Validity
#             Not Before: Jul 30 19:48:23 2012 GMT
#             Not After : Jul 25 19:48:23 2032 GMT
#         Subject: C = US, O = U.S. Government, OU = DoD, OU = PKI, CN = DoD Root CA 4
#         Subject Public Key Info:
#             Public Key Algorithm: id-ecPublicKey
#                 Public-Key: (256 bit)
#                 pub:
#                     ...
#                 ASN1 OID: prime256v1
#                 NIST CURVE: P-256
#         X509v3 extensions:
#             X509v3 Subject Key Identifier: 
#                 BD:C1:B9:6B:4D:F4:1D:EC:30:90:BF:62:73:C0:84:33:F2:71:24:85
#             X509v3 Key Usage: critical
#                 Digital Signature, Certificate Sign, CRL Sign
#             X509v3 Basic Constraints: critical
#                 CA:TRUE
#     Signature Algorithm: ecdsa-with-SHA256
CA=4
SERIAL=1
DAYS=7300
FAKETIME='2012-07-30 19:48:23'
ALGO="ecparam"
CURVE="-name prime256v1 -genkey"
SHA=256
EXTRAS="-addext keyUsage=digitalSignature,keyCertSign,cRLSign -addext basicConstraints=critical,CA:true"

make_ca

# Original DoDRoot3.cer
# Certificate:
#     Data:
#         Version: 3 (0x2)
#         Serial Number: 1 (0x1)
#         Signature Algorithm: sha256WithRSAEncryption
#         Issuer: C = US, O = U.S. Government, OU = DoD, OU = PKI, CN = DoD Root CA 3
#         Validity
#             Not Before: Mar 20 18:46:41 2012 GMT
#             Not After : Dec 30 18:46:41 2029 GMT
#         Subject: C = US, O = U.S. Government, OU = DoD, OU = PKI, CN = DoD Root CA 3
#         Subject Public Key Info:
#             Public Key Algorithm: rsaEncryption
#                 Public-Key: (2048 bit)
#                 Modulus: ...
#                 Exponent: 65537 (0x10001)
#         X509v3 extensions:
#             X509v3 Subject Key Identifier: 
#                 6C:8A:94:A2:77:B1:80:72:1D:81:7A:16:AA:F2:DC:CE:66:EE:45:C0
#             X509v3 Key Usage: critical
#                 Digital Signature, Certificate Sign, CRL Sign
#             X509v3 Basic Constraints: critical
#                 CA:TRUE
#     Signature Algorithm: sha256WithRSAEncryption
CA=3
SERIAL=1
DAYS=6494
FAKETIME='2012-03-20 18:46:41'
ALGO="genrsa"
CURVE="2048"
SHA=256
EXTRAS="-addext keyUsage=critical,digitalSignature,keyCertSign,cRLSign -addext basicConstraints=critical,CA:true"

make_ca

# Intermediates

# This function, `make_intermediate()`, is responsible for setting up the directory structure and generating the necessary files and certificates for an intermediate Certificate Authority (CA) in the context of the DoD PKI infrastructure.

# The function performs the following key steps:
# - Creates the directory structure for the intermediate CA
# - Generates the private key for the intermediate CA
# - Generates a Certificate Signing Request (CSR) for the intermediate CA
# - Signs the intermediate CA certificate using the root CA
# - Creates the CRL (Certificate Revocation List) for the intermediate CA
# - Generates an OCSP (Online Certificate Status Protocol) signing certificate for the intermediate CA

# This function is an implementation detail within the larger `create_ca.sh` script and is not intended to be used as a standalone API. The function assumes the existence of various configuration files and environment variables, and its usage is tightly coupled with the overall script logic.
function make_intermediate () {
      # Header for this intermediate CA
      gum style \
        --border normal \
        --border-foreground 212 \
        --padding "0 1" \
        --align center \
        "Creating Intermediate CA-$CA"

      # Setup directory structure silently
      INT_CA_DIR="$ROOT_CA_DIR/CA-$CA"
      mkdir -p $INT_CA_DIR/{certs,crl,newcerts,private,csr} > /dev/null 2>&1
      touch "$INT_CA_DIR/index.txt" > /dev/null 2>&1
      echo "01" > "$INT_CA_DIR/crlnumber" 2>/dev/null
      echo $SERIAL > $ROOT/serial 2>/dev/null

      # Generate key with status
      if openssl $ALGO -out "$ROOT_CA_DIR/private/DoD ID CA-$CA.key.pem" $CURVE > /dev/null 2>&1; then
          gum style --foreground 82 "✓ Generated DoD ID CA-$CA key"
          chmod 400 "$ROOT_CA_DIR/private/DoD ID CA-$CA.key.pem" > /dev/null 2>&1
      else
          gum style --foreground 196 "✗ Failed to generate DoD ID CA-$CA key"
          exit 1
      fi

      # Generate CSR with status
      if openssl req -config /opt/intermediate.conf \
            -key "$ROOT_CA_DIR/private/DoD ID CA-$CA.key.pem" \
            -new -sha$SHA \
            -out "$ROOT_CA_DIR/private/DoD ID CA-$CA.csr.pem" \
            -subj "/C=US/O=U.S. Government/OU=DoD/OU=PKI/CN=DOD ID CA-$CA" > /dev/null 2>&1; then
          gum style --foreground 82 "✓ Generated CSR for DoD ID CA-$CA"
      else
          gum style --foreground 196 "✗ Failed to generate CSR for DoD ID CA-$CA"
          exit 1
      fi

      # Sign intermediate cert with status
      if echo -e "y\ny\n" | faketime "$FAKETIME" openssl ca -config /opt/ca.conf \
            -extensions v3_intermediate_ca_$SIGNINGCA \
            -days $DAYS -notext -md sha$SHA \
            -in "$ROOT_CA_DIR/private/DoD ID CA-$CA.csr.pem" \
            -cert $ROOT_CA_DIR/certs/DoDRoot$SIGNINGCA.cert.pem \
            -keyfile $ROOT_CA_DIR/private/DoDRoot$SIGNINGCA.key.pem \
            -out "$ROOT_CA_DIR/certs/DoD ID CA-$CA.cert.pem" > /dev/null 2>&1; then
          gum style --foreground 82 "✓ Signed certificate for DoD ID CA-$CA"
          chmod 444 "$ROOT/certs/DoD ID CA-$CA.cert.pem" > /dev/null 2>&1
      else
          gum style --foreground 196 "✗ Failed to sign certificate for DoD ID CA-$CA"
          exit 1
      fi

      # Create certificate chain with status
      if cat "$ROOT/certs/DoD ID CA-$CA.cert.pem" \
            "$ROOT/certs/DoDRoot$SIGNINGCA.cert.pem" > "$ROOT/certs/DoD ID CA-$CA-chain.pem" 2>/dev/null; then
          gum style --foreground 82 "✓ Created certificate chain for DoD ID CA-$CA"
          chmod 444 "$ROOT/certs/DoD ID CA-$CA-chain.pem" > /dev/null 2>&1
      else
          gum style --foreground 196 "✗ Failed to create certificate chain for DoD ID CA-$CA"
          exit 1
      fi

      # Generate CRL with status
      OLD_ROOT=$ROOT
      export ROOT="$INT_CA_DIR"
      if openssl ca -config /opt/ca.conf \
            -keyfile "$ROOT_CA_DIR/private/DoD ID CA-$CA.key.pem" \
            -cert "$ROOT_CA_DIR/certs/DoD ID CA-$CA.cert.pem" \
            -gencrl -out "$ROOT_CA_DIR/crl/DoD ID CA-$CA.crl.pem" > /dev/null 2>&1; then
          gum style --foreground 82 "✓ Generated CRL for DoD ID CA-$CA"
          chmod 444 "$ROOT_CA_DIR/crl/DoD ID CA-$CA.crl.pem" > /dev/null 2>&1
      else
          gum style --foreground 196 "✗ Failed to generate CRL for DoD ID CA-$CA"
          exit 1
      fi

      # Generate OCSP key and cert with status
      if openssl $ALGO -out "$ROOT_CA_DIR/private/DoD ID CA-$CA-ocsp.key.pem" $CURVE > /dev/null 2>&1 && \
         openssl req -config /opt/intermediate.conf \
            -new -sha256 \
            -key "$ROOT_CA_DIR/private/DoD ID CA-$CA-ocsp.key.pem" \
            -out "$INT_CA_DIR/csr/ocsp.csr.pem" \
            -nodes \
            -subj "/C=US/ST=NY/L=NY/O=ILHICAS/OU=OSCP lda/CN=www.oscp.security.example.com/emailAddress=myemail@oscp.example.com" > /dev/null 2>&1 && \
         echo -e "y\ny\n" | faketime "$FAKETIME" openssl ca -config /opt/intermediate.conf \
            -extensions ocsp \
            -days 3650 \
            -notext -md sha256 \
            -in "$INT_CA_DIR/csr/ocsp.csr.pem" \
            -cert "$ROOT_CA_DIR/certs/DoD ID CA-$CA.cert.pem" \
            -keyfile "$ROOT_CA_DIR/private/DoD ID CA-$CA.key.pem" \
            -out "$INT_CA_DIR/certs/DoD ID CA-$CA-ocsp.cert.pem" > /dev/null 2>&1; then
          gum style --foreground 82 "✓ Generated OCSP certificate for DoD ID CA-$CA"
          chmod 444 "$INT_CA_DIR/certs/DoD ID CA-$CA-ocsp.cert.pem" > /dev/null 2>&1
      else
          gum style --foreground 196 "✗ Failed to generate OCSP certificate for DoD ID CA-$CA"
          exit 1
      fi

      export ROOT=$OLD_ROOT
      rm -f "$INT_CA_DIR/csr/ocsp.csr.pem" > /dev/null 2>&1
}


CA=59
SIGNINGCA=3
SERIAL=0305
DAYS=2192
FAKETIME='2019-04-02 13:38:32'
ALGO="genrsa"
CURVE="2048"
SHA=256

make_intermediate


CA=62
SIGNINGCA=3
SERIAL=054a
DAYS=2192
FAKETIME='2021-06-01 14:07:31'
ALGO="genrsa"
CURVE="2048"
SHA=256

make_intermediate


CA=63
SIGNINGCA=3
SERIAL=050f
DAYS=2192
FAKETIME='2021-04-06 13:55:54'
ALGO="genrsa"
CURVE="2048"
SHA=256

make_intermediate


CA=64
SIGNINGCA=3
SERIAL=054b
DAYS=2192
FAKETIME='2021-06-01 14:09:37'
ALGO="genrsa"
CURVE="2048"
SHA=256

make_intermediate


CA=65
SIGNINGCA=3
SERIAL=054c
DAYS=2192
FAKETIME='2021-06-01 14:11:23'
ALGO="genrsa"
CURVE="2048"
SHA=256

make_intermediate

#Creating certificate chain with intermediate and root
# cat /root/ca/intermediate/certs/intermediate.cert.pem \
#       /root/ca/certs/ca.cert.pem > /root/ca/intermediate/certs/ca-chain.cert.pem
# chmod 444 /root/ca/intermediate/certs/ca-chain.cert.pem


# #Create a Certificate revocation list of the intermediate CA
# openssl ca -config /root/ca/intermediate/openssl.cnf \
#       -gencrl -out /root/ca/intermediate/crl/intermediate.crl.pem
