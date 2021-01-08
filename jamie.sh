#!/usr/bin/env bash

rm -fr tmp
mkdir tmp
cd tmp

mkdir certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial

# CA key
openssl genrsa -out private/ca.key.pem 2048
chmod 400 private/ca.key.pem

# CA cert
openssl req -config ../jamie-openssl.cnf \
      -key private/ca.key.pem \
      -new -x509 -days 7300 -sha256 -extensions v3_ca \
      -out certs/ca.cert.pem
chmod 444 certs/ca.cert.pem
