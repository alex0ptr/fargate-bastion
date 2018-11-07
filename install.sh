#!/bin/sh
set -e
set -u
set -o pipefail

stackName=${1:-bastion-dev}

echo "stackname will be: $stackName"

function finish {
    rm -Rf tmp
}
trap finish EXIT

echo "getting accountId..."
accountId=$(set -e; aws sts get-caller-identity --query 'Account' --output text)

echo "creating stack..."
aws cloudformation create-stack \
    --stack-name $stackName \
    --template-body file://cfn.yml \
    --capabilities CAPABILITY_IAM
aws cloudformation wait stack-create-complete --stack-name $stackName

echo "creating host keys..."
mkdir tmp
ssh-keygen -t dsa -f tmp/ssh_host_dsa_key -N ''
ssh-keygen -t rsa -f tmp/ssh_host_rsa_key -N ''
ssh-keygen -t ed25519 -f tmp/ssh_host_ed25519_key -N ''
ssh-keygen -t ecdsa -f tmp/ssh_host_ecdsa_key -N ''

echo "uploading host keys..."
aws s3 sync tmp/ s3://${stackName}-keyfiles-${accountId}/host-keys/ 

echo "building docker image..."
repository=$(set -e; aws ecr describe-repositories \
    --query "repositories[?repositoryName=='alex0ptr/aws-bastion-$stackName'].repositoryUri | [0]" \
    --output text)
docker build docker -t $repository

echo "pushing image to ecr"
eval `aws ecr get-login --no-include-email`
docker push $repository


