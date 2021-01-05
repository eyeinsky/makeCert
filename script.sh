#!/usr/bin/env bash

just_pem() {
    cat | sed -ne '/-----BEGIN /,/-----END /p'
}

p12_extract_cert() {
    local p12="$1"
    local password="$2"
    openssl pkcs12 -info -in $p12 -nokeys -password "pass:$password" | just_pem
}

p12_extract_key() {
    local p12="$1"
    local password="$2"
    openssl pkcs12 -info -in $p12 -nodes -nocerts -password "pass:$password" 2>/dev/null | just_pem
}

key_extract_pub() {
    local key="$1"
    openssl rsa -in "$key" -pubout
}

cert_verify() {
    local ca="$1"
    local cert="$2"
    openssl verify -verbose -CAfile "$ca" "$cert"
}

p12_view_cert() {
    local p12="$1"
    local pw="$2"
    local tmp_cert="$(mktemp)"
    p12_extract_cert "$p12" "$pw" > "$tmp_cert"
    openssl x509 -in "$tmp_cert" -text
}

$@
