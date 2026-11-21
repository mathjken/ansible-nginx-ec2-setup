# Ansible Nginx EC2 Deployment

## Project Overview

This project demonstrates infrastructure provisioning with **Terraform** and automated server configuration with **Ansible**.

Terraform provisions an Ubuntu EC2 instance on AWS. Ansible connects to the instance over SSH, installs and configures Nginx, and deploys a custom HTML landing page.

The result is a publicly accessible website served by Nginx.

## Architecture

1. Terraform provisions the AWS infrastructure.
2. An EC2 Ubuntu server is launched with a public IP address.
3. A security group allows HTTP traffic and restricts SSH access to an approved IP address.
4. Ansible connects to the EC2 instance using SSH.
5. Ansible installs and enables Nginx.
6. Ansible deploys the custom website.
7. The website is verified using a browser and an HTTP response check.

## Technologies

- AWS EC2
- Terraform
- Ansible
- Ubuntu Linux
- Nginx
- SSH
- Git and GitHub

## Repository Structure

```text
ansible-nginx-ec2-setup/
├── ansible/
│   ├── files/
│   │   └── index.html
│   ├── inventory.ini
│   └── playbook.yml
├── docs/
│   └── evidence/
├── terraform/
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   ├── versions.tf
│   └── .terraform.lock.hcl
├── .gitignore
└── README.md


Prerequisites
- An AWS account with permissions to create EC2 and security-group resources.
- AWS CLI configured with an appropriate profile.
- Terraform installed.
- Ansible installed.
- An SSH key pair.
- An Ubuntu AMI available in the selected AWS region.
Deployment
1. Configure AWS
Configure your AWS CLI credentials and ensure the AWS profile used in terraform/versions.tf is available.
2. Configure Terraform
Go to the Terraform directory:
cd terraform


Create your local terraform.tfvars file with the required variable values. At minimum, configure:
ssh_allowed_cidr = "YOUR_PUBLIC_IP/32"
ami_id           = "YOUR_UBUNTU_AMI_ID"


Use an Ubuntu AMI ID valid for your selected AWS region. Restrict SSH access to your own trusted public IP address.

Ensure the public key path in main.tf points to your local SSH public key.
3. Initialise and validate Terraform
terraform init
terraform fmt -check
terraform validate
terraform plan


Review the plan before applying it.
4. Provision the infrastructure
terraform apply


Review and approve the proposed changes when prompted.

Retrieve the public IP address:
terraform output -raw public_ip


5. Configure the Ansible inventory
Update ansible/inventory.ini with the EC2 public IP address and the correct local SSH private-key path.

Test connectivity:
ansible -i ansible/inventory.ini web -m ping


A successful connection returns pong.
6. Validate and run the Ansible playbook
From the project root:
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --syntax-check
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml


Run the playbook again to check idempotency. A successful second run should report changed=0 when no configuration changes are required.
7. Verify the website
Open the website URL using the EC2 public IP address:
http://YOUR_EC2_PUBLIC_IP


You can also verify the HTTP response:
curl -I http://YOUR_EC2_PUBLIC_IP


A successful deployment should return HTTP/1.1 200 OK.
Evidence
Screenshots documenting the deployment and verification process are stored in docs/evidence/.

They include Terraform validation and planning, the running EC2 instance, security-group rules, SSH connectivity, Ansible execution, idempotency, the live website, and HTTP verification.
Security Considerations
- Restrict SSH access to a trusted public IP using a /32 CIDR.
- Do not expose SSH to 0.0.0.0/0.
- Never commit private SSH keys, AWS credentials, Terraform state files, plan files, or personal terraform.tfvars files.
- Keep sensitive configuration outside version control.
- Review Terraform plans before applying infrastructure changes.
Cleanup
When the infrastructure is no longer required, remove the resources created by Terraform:
terraform -destroy


Run this from the Terraform directory and review the destruction plan carefully before confirming. AWS resources may incur charges while they remain provisioned.
Learning Outcomes
This project demonstrates practical experience with:
- Infrastructure as Code using Terraform.
- AWS EC2 provisioning.
- Linux server administration.
- SSH-based remote access.
- Ansible inventories, modules, and playbooks.
- Nginx installation and configuration.
- Automated website deployment.
- Ansible idempotency.
- Infrastructure and application verification.
