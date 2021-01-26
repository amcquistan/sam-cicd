#!/bin/bash

#########################################################################################
# Author: Adam McQuistan                                                                #
# Description: Build script for SAM project which verifies required environment         #
#              variables are present, runs unit tests, builds project resources,        #
#              packages those resources into a zip file, uploads those resources        #
#              to S3 and, generates a local deployment ready SAM template updated       #
#              with CodeUri paths to the packaged resources on S3.                      #
#                                                                                       #
# Local Execution Example:                                                              #
#   $ STACK_NAME=sam-cicd-dev ENV_TYPE=dev S3_BUCKET=tci-sam-code S3_PREFIX=sam-cicd-dev ./deploy.sh          #
#########################################################################################

set -e

if [ ! -f template.yaml ]; then
  echo "Building and packaging must occur in the project root directory along side the template.yaml file"
  exit 1
fi

if [[ -z $STACK_NAME ]]; then
  echo "Missing environment variable STACK_NAME"
  exit 1
fi

if [[ -z $ENV_TYPE ]]; then
  echo "Missing environment variable ENV_TYPE"
  exit 1
fi

if [[ -z $S3_BUCKET ]]; then
  echo "Missing environment variable for S3_BUCKET"
  exit 1
fi

if [[ -z $S3_PREFIX ]]; then
  echo "Missing environment variable for S3_PREFIX"
  exit 1
fi



sam build && sam deploy --stack-name $STACK_NAME --s3-bucket $S3_BUCKET --s3-prefix $S3_PREFIX \
  --parameter-overrides EnvType=$ENV_TYPE \
  --capabilities CAPABILITY_IAM --no-confirm-changeset


