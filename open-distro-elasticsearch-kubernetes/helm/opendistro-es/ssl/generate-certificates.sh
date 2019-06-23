#!/usr/bin/env bash

# Prerequisites :
# cfssljson (https://github.com/cloudflare/cfssl) Cloudflare's PKI and TLS toolkit
# brew install cfssl

# Tuto: https://propellered.com/post/cfssl_setting_up/

rm -rf ./certificates

# 01 - Creation of Root CA
echo "--------------------------------------------"
echo "Root CA Creation"
echo "--------------------------------------------"
mkdir -p ./certificates/ca-root
cfssl genkey -initca ./config/ca-root.csr.json | cfssljson -bare certificates/ca-root/ca-root
rm certificates/ca-root/ca-root.csr
#openssl x509 -in certificates/ca-root/ca.pem -text -noout

# 02 - Creation of Intermediate CA
echo ""
echo "--------------------------------------------"
echo "Intermediate CA Creation"
echo "--------------------------------------------"
mkdir -p ./certificates/ca-inter
cfssl gencert -ca=certificates/ca-root/ca-root.pem -ca-key=certificates/ca-root/ca-root-key.pem -config=config/config.json -profile=intermediate config/ca-intermediate.csr.json | cfssljson -bare certificates/ca-inter/ca-inter
# Change key format to PKCS#8
openssl pkcs8 -topk8 -nocrypt -in certificates/ca-inter/ca-inter-key.pem -v1 PBE-SHA1-3DES -out certificates/ca-inter/key.pem
rm certificates/ca-inter/ca-inter-key.pem
rm certificates/ca-inter/ca-inter.csr

# # Confirm compatibilty between Key and Certifcate
# openssl pkey -in certificates/ca-inter/key.pem -pubout -outform pem | openssl sha256 
# openssl x509 -in certificates/ca-inter/ca.pem -pubkey -noout -outform pem | openssl sha256 


# All Open Distro certificates creation
certs_creation()
{
    ca_inter_path="certificates/ca-inter"
    config_file="config/config.json"

    echo ""
    echo "--------------------------------------------"
    echo "Certs creation for $1.csr.json"
    echo " - folder name: $1"
    echo " - config file: config/$1.csr.json"
    echo "--------------------------------------------"

    mkdir -p ./certificates/$1
    cfssl gencert -ca=${ca_inter_path}/ca-inter.pem -ca-key=${ca_inter_path}/key.pem -config=${config_file} -profile=server config/$1.csr.json | cfssljson -bare certificates/$1/$1-crt
    # Change key format to PKCS#8
    openssl pkcs8 -topk8 -nocrypt -in certificates/$1/$1-crt-key.pem -v1 PBE-SHA1-3DES -out certificates/$1/key.pem
    rm certificates/$1/$1-crt-key.pem
    rm certificates/$1/$1-crt.csr
}

certs_creation od-admin
certs_creation od-kibana
certs_creation od-elk-rest
certs_creation od-elk-transport