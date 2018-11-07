#!/bin/sh
set -e
set -u
set -o pipefail

stackName=${1:-bastion-dev}
clusterName=$stackName-cluster

firstSubnet=$(set -e; aws cloudformation describe-stack-resources \
    --stack-name $stackName \
    --query 'StackResources[?ResourceType==`AWS::EC2::Subnet`].PhysicalResourceId | [0]')
secondSubnet=$(set -e; aws cloudformation describe-stack-resources \
    --stack-name $stackName \
    --query 'StackResources[?ResourceType==`AWS::EC2::Subnet`].PhysicalResourceId | [1]')

securityGroup=$(set -e; aws cloudformation describe-stack-resources \
    --stack-name $stackName \
    --query 'StackResources[?ResourceType==`AWS::EC2::SecurityGroup`].PhysicalResourceId | [0]')

echo "starting bastion... $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
task=$(set -e; aws ecs run-task \
    --cluster $clusterName \
    --task-definition bastion \
    --count 1 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[${firstSubnet},${secondSubnet}],securityGroups=[${securityGroup}],assignPublicIp='ENABLED'}" \
    --query 'tasks[0].taskArn' \
    --output text )

function killTask {
    echo "stopping task..."
    aws ecs stop-task --cluster $clusterName --task $task >/dev/null 2>&1
}
trap killTask EXIT

echo "Task started, you can see it's progress and public ip here: "
echo "https://console.aws.amazon.com/ecs/home?region=us-east-1#/clusters/$clusterName/tasks"

echo "waiting for container running state..."
aws ecs wait tasks-running --cluster $clusterName --tasks $task

echo "done waiting. $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "getting ip..."
eni=$(set -e; aws ecs describe-tasks \
    --cluster $clusterName \
    --tasks $task \
    --query 'tasks[0].attachments[0].details[?name == `networkInterfaceId`].value' \
    --output text)
ip=$(set -e; aws ec2 describe-network-interfaces \
    --network-interface-ids $eni \
    --query 'NetworkInterfaces[0].Association.PublicIp' \
    --output text)

echo "container is up the bastion should be available at:"
echo "ssh ops@$ip -p 42"

echo "hit enter to kill bastion"
read

