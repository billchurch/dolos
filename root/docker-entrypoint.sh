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
    openssl ocsp -index "/app/CA-$CA/index.txt" -port 2560 \
      -rkey "/app/private/DoD ID CA-$CA-ocsp.key.pem" \
      -rsigner "/app/CA-$CA/certs/DoD ID CA-$CA-ocsp.cert.pem" \
      -CA "/app/certs/DoD ID CA-$CA.cert.pem" \
      -text
  PID=$!
  inotifywait -e modify -e move -e create -e delete -e attrib -r "/app/CA-$CA/index.txt"
  kill $PID
done
