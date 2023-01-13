#!/bin/sh
set -a 

ROOT=/app
CA=59

sigint_handler()
{
  kill $PID
  exit
}

trap sigint_handler SIGINT

while true; do
    openssl ocsp -port 0.0.0.0:2560 -text -sha256 \
        -index $ROOT/index.txt \
#       -CA /root/ca/intermediate/certs/ca-chain.cert.pem \
        -CA "$ROOT/certs/DoD ID CA-$CA.cert.pem" \
        -rkey "$ROOT/private/DoD ID CA-$CA.key.pem" \
        -rsigner "$ROOT/certs/DoD ID CA-$CA.cert.pem"
  PID=$!
  inotifywait -e modify -e move -e create -e delete -e attrib -r /root/ca/intermediate/index.txt
  kill $PID
done