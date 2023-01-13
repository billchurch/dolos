#!/bin/sh
#First generate the key for the client
set -a 

#NAME="GRABER.ANTHONY.J.III"
#EDIPI="1042156821"
NAME="JOHNSON.ROBERT.A"
EDIPI="4444309999"
AGENCY="157004"
UPN="$EDIPI$AGENCY@mil"
SUBJ="$NAME.$EDIPI"
CN="/C=US/O=U.S. Government/OU=DoD/OU=PKI/OU=USAF/CN="
STARTDATE="20210306000000Z"
ENDDATE="20230301235959Z"
URN="$(uuidgen -r | tr '[:lower:]' '[:upper:]')"
CERTSERIAL="030ee92c"
FASCN="$(openssl rand -hex 20 | tr '[:lower:]' '[:upper:]')"
NATIONALITY="3012301006082B06010505070904310413025553"

EXTENSIONS="usr_cert"
SIGNINGCA="59"
ROOT=/app
# echo $CERTSERIAL > $ROOT/serial

openssl genrsa -out "$ROOT/private/$SUBJ.key.pem" 2048 
chmod 400 "$ROOT/private/$SUBJ.key.pem"

#Then create the certificate signing request
openssl req -config /opt/intermediate.conf \
      -key "$ROOT/private/$SUBJ.key.pem" \
      -new -sha256 -out "$ROOT/csr/$SUBJ.csr.pem" \
      -subj "$CN$SUBJ" 

#Now sign it with the intermediate CA


echo -e "y\ny\n" | openssl ca -config /opt/intermediate.conf \
      -extensions $EXTENSIONS -days 365 -notext -md sha256 \
      -cert "$ROOT/certs/DoD ID CA-$SIGNINGCA.cert.pem" \
      -keyfile "$ROOT/private/DoD ID CA-$SIGNINGCA.key.pem" \
      -startdate $STARTDATE \
      -enddate $ENDDATE \
      -in "$ROOT/csr/$SUBJ.csr.pem" \
      -out "$ROOT/certs/$SUBJ.cert.pem"

chmod 444 $ROOT/certs/$SUBJ.cert.pem

rm "$ROOT/csr/$SUBJ.csr.pem" 

# cat $ROOT/certs/$SUBJ.cert.pem