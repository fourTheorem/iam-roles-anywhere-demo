# IAM Roles Anywhere Demo

This repository provides a demonstration of IAM Roles Anywhere, a solution for using X.509 certificates to assume IAM roles in AWS environments. The demo showcases the process of creating a Certificate Authority (CA), generating credentials, and utilizing them to assume roles.

## Creating the CA

The following commands explain how to create a CA for testing purposes. Please note that this CA is not suitable for production use, where you should use ACM Private Certificate Authority or a fully-implemented, reliably secure private CA.

1. **Generate the CA private key**: Run the following command to generate a private key for your CA:
   ```bash
   openssl ecparam -genkey -name secp384r1 -out ca.key
   ```
   This command will generate a private key and save it in the file `ca.key`.

2. **Edit `root_ca_request.config` and customize**: Make any necessary customizations to the `root_ca_request.config` file, which contains the configuration for the CA request.

3. **Generate the CA request**: Execute the following command to generate the CA request using the private key and configuration:
   ```bash
   openssl req -new -key ca.key -out ca.req -nodes -config root_ca_request.config
   ```
   This will generate the CA request and save it in the file `ca.req`.

4. **Edit `root_cert.config` and customize**: Customize the `root_cert.config` file according to your requirements.

5. **Generate the CA certificate**: Use the following command to generate the CA certificate by self-signing the CA request:
   ```bash
   openssl ca -out ca.pem -keyfile ca.key -selfsign -config root_cert.config -in ca.req
   ```
   The CA certificate will be generated and saved in the file `ca.pem`.

6. **Create the client key**: Generate a private key for the client using the following command:
   ```bash
   openssl ecparam -genkey -name secp384r1 -out client.key
   ```
   The client private key will be generated and saved in the file `client.key`.

7. **Edit and customize the basic CSR config file (`client_request.config`)**: Make any necessary modifications to the `client_request.config` file, which contains the configuration for the client's Certificate Signing Request (CSR).

8. **Generate the client CSR**: Run the following command to generate the client's CSR using the client private key and CSR configuration:
   ```bash
   openssl req -new -sha512 -nodes -key client.key -out client.csr -config client_request.config
   ```
   The client CSR will be generated and saved in the file `client.csr`.

9. **Edit and customize `client_cert.config`**: Customize the `client_cert.config` file based on your preferences and requirements.

10. **Generate the client certificate**: Use the following command to generate the client certificate by signing the client CSR with the CA:
    ```bash
    openssl x509 -req -sha512 -days 30 -in client.csr -CA ca.pem -CAkey ca.key -CAcreateserial -out client.pem -extfile client_cert.config
    ```
    The client certificate will be generated and saved in the file `client.pem`.

## Create a Roles Anywhere Trust Anchor, Role, and Profile

To create a Roles Anywhere Trust Anchor, Role, and Profile in AWS, execute the following command:

```bash
aws cloudformation deploy --template template.yaml --stack-name roles-anywhere-demo --parameter-overrides OU=IT X509CertificateData="$(cat ca.pem)" --capabilities CAPABILITY_NAMED_IAM --disable-rollback
```

This command deploys an AWS Cloud

Formation stack using the `template.yaml` file. The stack creates the necessary resources for the Roles Anywhere demo, including the Trust Anchor, IAM Role, and IAM Profile. The `OU` parameter specifies the Organizational Unit for the role, and `X509CertificateData` is the content of the CA certificate (`ca.pem`).

## Generate credentials using the certificate and the IAM Roles Anywhere Trust Anchor, Role, and Profile

To generate credentials using the client certificate and the IAM Roles Anywhere Trust Anchor, Role, and Profile, run the following command:

```bash
./get_creds.sh
```

This command executes the `get_creds.sh` script, which performs the necessary steps to obtain temporary AWS credentials using the client certificate and the created IAM resources. The script facilitates the process of assuming the IAM role and setting the appropriate environment variables for subsequent AWS operations.

Feel free to explore and modify the provided scripts and configuration files to adapt the demo to your specific use cases and requirements.

## License

This demo is provided under the [MIT License](LICENSE). Feel free to use, modify, and distribute it according to the terms of the license.
