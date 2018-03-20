#!/bin/sh
set -e
set -u

stackName=${1:-bastion-dev}

echo "getting accountId..."
accountId=$(set -e; aws sts get-caller-identity --query 'Account' --output text)

set +e
echo "clearing bucket..."
aws s3 rm s3://${stackName}-keyfiles-${accountId} --recursive

echo "clearing docker image..."
aws ecr batch-delete-image --repository-name alex0ptr/aws-bastion-$stackName --image-ids imageTag=latest

set -e
echo "clearing stack..."
aws cloudformation delete-stack --stack-name $stackName
aws cloudformation wait stack-delete-complete --stack-name $stackName

