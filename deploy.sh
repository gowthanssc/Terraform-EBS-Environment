#!/bin/bash

# usage: ./deploy.sh api staging us-east-1 f0478bd7c2f584b41a49405c91a439ce9d944657

echo Terraform initialization started
./terraform init >> /dev/null

echo Terraform provisioning started
./terraform apply >> /dev/null

echo Wait for sometime
sleep 2m

set -e
start=`date +%s`

# Name of your application, should be the same as in setup
NAME=$1

# Stage/environment e.g. `staging`, `test`, `production``
STAGE=$2

# AWS Region where app should be deployed e.g. `us-east-1`, `eu-central-1`
REGION=$3

# Hash of commit for better identification
SHA1=$4

if [ -z "$NAME" ]; then
  echo "Application NAME was not provided, aborting deploy!"
  exit 1
fi

if [ -z "$STAGE" ]; then
  echo "Application STAGE was not provided, aborting deploy!"
  exit 1
fi

if [ -z "$REGION" ]; then
  echo "Application REGION was not provided, aborting deploy!"
  exit 1
fi

if [ -z "$SHA1" ]; then
  echo "Application SHA1 was not provided, aborting deploy!"
  exit 1
fi

EB_BUCKET=terraformzip
ENV=apienv
VERSION=$STAGE-$SHA1-$(date +%s)
ZIP=index.zip

# Create a new application version with the zipped up Dockerrun file
aws elasticbeanstalk create-application-version --application-name $NAME --version-label $VERSION --source-bundle S3Bucket=$EB_BUCKET,S3Key=$ZIP

# Update the environment to use the new application version
aws elasticbeanstalk update-environment --environment-name $ENV --version-label $VERSION

end=`date +%s`

echo Deploy ended with success! Time elapsed: $((end-start)) seconds
