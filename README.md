# EKS Cluster

Terraform configuration files to provision an EKS cluster on AWS for RC Support.

## Instructions

1. Clone this repo `https://github.com/officialdarnyc/rc-eks.git`
2. Enter the directory `cd rc-eks`
3. Initialize your terraform workspace; `terraform init`
2. Validate the code to be sure no issue; `terraform validate`
3. View the infrastructure to be built and output the terraform plan; `terraform plan -out eks.tfplan`
4. Use the `eks.tfplan` to deploy the infrastructure; `terraform apply -auto-approve eks.tfplan`

## Usage

Add the created EKS cluster configuration to your `kube-config` to interact with the cluster using `kubectl`
```bash
aws eks --region us-east-2 update-kubeconfig --name support-eks
```
