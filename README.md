# Fargate Bastion
This is an example project that demonstrates the usage of AWS Fargate as a bastion host.

Basically it is a CloudFormation Stack with an ECS Task Definition that is intended to be started from your shell, whenever you need to SSH into your instances which reside in private subnets. Once the container is provisioned, it pulls host-keys and public user-keys from an S3 Bucket, configures the `authorized_keys` file of the `ops` user and finally starts the SSH daemon. The container is assigned a public IP for easy connection from everywhere with your correspending private key. 

The example consists of:
* an ECS Cluster 
* a VPC for the cluster
* a Task Definition and a Docker Image hosted on ECR
* an S3 Bucket to store host and user keys
* a CloudWatch LogGroup to collect container logs
* all neccessary IAM policies/roles

Asciinema:
[![asciicast](https://asciinema.org/a/o4svO0CIu1XD6fCd9meVa5M99.png)](https://asciinema.org/a/o4svO0CIu1XD6fCd9meVa5M99)


## Prerequisites

You'll need installed and configured:
* an AWS account
* a recent aws-cli
* `AWS_DEFAULT_REGION` and `AWS_DEFAULT_PROFILE` set in your environment correctly (Fargate is currently only available in `eu-west-1`, `us-east-1`, `us-east-2`, `us-west-2`)
* a recent Docker installation

## Howto

You can install the whole stack by running:
```
./install.sh [stack-name]
```

Naming the stack is optional, but is required if you intend to deploy multiple stacks or want to redeploy directly after deletion (S3 resource names may not be available directly after deletion). If you choose a custom stackname during creation you must provide it again in the following executions.

After stack creation you need to upload your public key:
```
./upload-key.s ~/.ssh/id.pub [stack-name]
```

Finally run your container, whenever you wish to connect:
```
./run-bastion.sh [stack-name]
```

The script will output the bastion's IP by providing an SSH command:
```
ssh ops@54.89.100.178 -p 42
```


## About me
Hi! I'm Alex, a Cloud Developer passionate about DevOps, cloud-native microservices and the reactive programming paradigm. Say hi to me on Twitter: `@alex0ptr`.
