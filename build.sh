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
#     $ ENV_TYPE=dev S3_BUCKET=my-packaging-bucket REGION=us-east-2 ./scripts/build.sh  #
#########################################################################################

set -e

if [ ! -f template.yaml ]; then
  echo "Building and packaging must occur in the project root directory along side the template.yaml file"
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

if [[ -z $REGION ]]; then
  echo "Missing environment variable for REGION"
  exit 1
fi

python -m pytest tests/ -v > test-report.txt

sam build --parameter-overrides EnvType=$ENV_TYPE --region $REGION \
  && sam package --s3-bucket $S3_BUCKET > deploy-template.yaml
