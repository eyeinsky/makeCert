.PHONY: all
all: new-self-signed

key.pem:
	openssl genrsa -out key.pem 2048

csr.pem: key.pem
	openssl req -config openssl.cnf -new -key key.pem -out csr.pem

ca.key.pem:
	${MAKE} key.pem
	mv key.pem ca.key.pem

# Create a CSR to be self-signed (as a CA by definition is)
ca.crt.pem: ca.key.pem
	openssl req -config openssl.cnf -new -key ca.key.pem -out ca.csr.pem
	# openssl x509 -req -days 365 -in ca.csr.pem -signkey ca.key.pem -out ca.crt.pem
	openssl ca -selfsign -in ca.csr.pem -out ca.crt.pem -config openssl.cnf # -extensions root_ca_ext
	rm ca.csr.pem

# Certificates

.PHONY: new-self-signed
new-self-signed:
	${MAKE} csr.pem
	cp key.pem ca.key.pem
	openssl x509 -req -days 365 -in csr.pem -signkey ca.key.pem -out self-signed.pem

# Create a CSR from a possibly existing key.pem, sign it with a
# possibly existing ca.key.pem
crt.pem: ca.crt.pem
	${MAKE} csr.pem
	# must exist: key.pem
	openssl x509 -req -days 365 -in csr.pem -signkey ca.key.pem -out crt.pem
	rm csr.pem

# Creates new key, extracts public key, signs it with possibly
# existing ca.key.pem and packs the key and cert into a .p12
client.p12: crt.pem ca.crt.pem
	# must exist: key.pem ca.key.pem
	cat ca.crt.pem crt.pem > chain.pem
	openssl pkcs12 -export -inkey key.pem -in chain.pem -out client.p12

# Clean

.PHONY: clean
clean:
	rm -f *.pem
