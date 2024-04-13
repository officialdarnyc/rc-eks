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

### Install and Configure Amazon EBS CSI driver for the new EKS cluster

The steps in this section are required to avoid a similar issue as [this](https://stackoverflow.com/questions/75758115/persistentvolumeclaim-is-stuck-waiting-for-a-volume-to-be-created-either-by-ex) one

1. Install `eksctl` CLI if not present

Using Homebrew
```bash
brew tap weaveworks/tap
brew install weaveworks/tap/eksctl
```
Using choco on Windows
```bash
choco install eksctl
```

2. Enable IAM OIDC provider
```bash
eksctl utils associate-iam-oidc-provider --region=us-east-2 --cluster=support-eks --approve
```

3. Create Amazon EBS CSI driver IAM role
```bash
eksctl create iamserviceaccount \
  --region us-east-2 \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster support-eks \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --role-only \
  --role-name AmazonEKS_EBS_CSI_DriverRole
```

4. Add the Amazon EBS CSI add-on. Before running the command to add the EBS CSI add-on, confirm that you have the right `AWS_REGION` set in the your environment variable
```bash
echo $AWS_REGION
eksctl create addon --name aws-ebs-csi-driver --cluster support-eks --service-account-role-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/AmazonEKS_EBS_CSI_DriverRole --force
``` 
