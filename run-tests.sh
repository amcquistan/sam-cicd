#!/bin/bash

set -e

if [ ! -f template.yaml ]; then
  echo "Building and packaging must occur in the project root directory along side the template.yaml file"
  exit 1
fi

python -m pytest tests/ -v > test-report.txt
