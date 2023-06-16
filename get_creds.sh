#!/bin/bash

set -euo pipefail
OUTPUTS=$(aws cloudformation describe-stacks --stack-name roles-anywhere-demo --query "Stacks[0].Outputs")

TRUST_ANCHOR_ARN=$(echo $OUTPUTS | jq -r '.[] | select(.OutputKey == "TrustAnchorArn") | .OutputValue')
PROFILE_ARN=$(echo $OUTPUTS | jq -r '.[] | select(.OutputKey == "ProfileArn") | .OutputValue')
ROLE_ARN=$(echo $OUTPUTS | jq -r '.[] | select(.OutputKey == "RoleArn") | .OutputValue')

CREDS=$(aws_signing_helper credential-process \
  --certificate ./server.pem \
  --private-key ./server.key \
  --trust-anchor-arn ${TRUST_ANCHOR_ARN} \
  --profile-arn ${PROFILE_ARN} \
  --role-arn ${ROLE_ARN})

export AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r '.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r '.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $CREDS | jq -r '.SessionToken')
export AWS_SESSION_EXPIRATION=$(echo $CREDS | jq -r '.Expiration')

aws sts get-caller-identity --no-cli-pager --output table
echo

echo export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
echo export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
echo export AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN
echo export AWS_SESSION_EXPIRATION=$AWS_SESSION_EXPIRATION

