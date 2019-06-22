#!/usr/bin/env bash

# Prerequisites :
# cfssljson (https://github.com/cloudflare/cfssl) Cloudflare's PKI and TLS toolkit
# brew install cfssl

# Tuto: https://propellered.com/post/cfssl_setting_up/

# 01 - Creation of Root CA
mkdir -p ./certificates/CAroot
cfssl genkey -initca ./config/01-ca-root.json |cfssljson -bare certificates/CAroot/ca

#openssl x509 -in certificates/CAroot/ca.pem -text -noout


# 02 - Creation of Intermediate CA
mkdir -p ./certificates/CAinter
cfssl genkey -initca ./config/01-ca-root.json |cfssljson -bare ./certificates/CAinter/ca
cfssl gencert -ca=certificates/CAroot/ca.pem -ca-key=certificates/CAroot/ca-key.pem -config=config/ca-config.json -profile=intermediate config/02-ca-intermediate.json | cfssljson -bare certificates/CAinter/ca
# Change key format to PKCS#8
openssl pkcs8 -topk8 -nocrypt -in certificates/CAinter/ca-key.pem -v1 PBE-SHA1-3DES -out certificates/CAinter/key.pem
rm certificates/CAinter/ca-key.pem

# openssl pkcs8 -in ./certificates/CAinter/ca-key.pem
openssl x509 -noout -modulus -in certificates/CAinter/ca.pem | openssl md5
openssl rsa -noout -text -in certificates/CAinter/key.pem | openssl md5