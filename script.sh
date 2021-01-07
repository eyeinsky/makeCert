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
    p12_extract_cert "$p12" "$pw" | openssl x509 -text
}


p12_connect() {
    local p12="$1"
    local pw="$2"
    local host="$3"
    curl --verbose --cert-type P12 --cert "$p12:$pw" "$host"
}

is_self_signed() {
    let cert="$1"
    openssl verify -no-CAfile -no-CApath "$cert"
}

DEFAULT='echo No command specified'
${@:-$DEFAULT}
