# IAM Roles Anywhere Demo

## Creating the CA

This is a simple way to create a demo CA for testing purposes only! For production use, use ACM Private Certificate Authority or a fully-implemented, reliably secure private CA.


Generate the CA private key: Use the following command to generate a private key for your CA:
```bash
openssl ecparam -genkey -name secp384r1 -out ca.key
```

This command will generate a private key and save it in the file ca.key.

Edit `root_ca_request.config` and customise.

```bash
openssl req -new -key cat.key -out ca.req -nodes -config root_ca_request.config
```

Edit `root_cert.config` and customise.

```bash
openssl ca -out ca.pem -keyfile ca.key -selfsign -config root_cert.config -in ca.req
```

Create the client key
```bash
openssl ecparam -genkey -name secp384r1 -out server.key
```

Edit and customise the basic CSR config file, `server_request.config`.

```bash
openssl req -new -sha512 -nodes -key server.key -out server.csr -config server_request.config
```

Edit and customise `server_cert.config`

```bash
openssl x509 -req -sha512 -days 30 -in server.csr -CA ca.pem -CAkey ca.key -CAcreateserial -out server.pem -extfile server_cert.config
```

## Create a Roles Anywhere Trust Anchor, Role and Profile

```bash
aws cloudformation deploy --template template.yaml --stack-name roles-anywhere-demo --parameter-overrides OU=IT X509CertificateData="$(cat ca.pem)" --capabilities CAPABILITY_NAMED_IAM --disable-rollback
```

## Generate credentials using the certificate and the IAM Roles Anywhere Trust Anchor, Role and Profile

```bash
./get_creds.sh
```

