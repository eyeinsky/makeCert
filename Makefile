.PHONY: all
all: new-self-signed

key.pem:
	openssl genrsa -out key.pem 2048

csr.pem: key.pem
	openssl req -config openssl.cnf -new -key key.pem -out csr.pem

ca.pem:
	${MAKE} key.pem
	mv key.pem ca.pem

# Certificates

# .PHONY
new-self-signed:
	${MAKE} key.pem
	cp key.pem ca.pem
	openssl x509 -req -days 365 -in csr.pem -signkey ca.pem -out self-signed.pem

# .PHONY
new-ca-signed: ca.pem
	${MAKE} csr.pem
	openssl x509 -req -days 365 -in csr.pem -signkey ca.pem -out crt.pem
	rm csr.pem

# Clean

.PHONY: clean
clean: rm -f *.pem
