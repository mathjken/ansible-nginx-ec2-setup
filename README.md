Ansible Nginx EC2 Deployment
Project Overview
This project demonstrates infrastructure provisioning with Terraform and automated server configuration with Ansible.

Terraform provisions an Ubuntu EC2 instance on AWS. Ansible connects to the instance over SSH, installs and configures Nginx, and deploys a custom HTML landing page.

The result is a publicly accessible website served by Nginx.

Architecture
Terraform provisions the AWS infrastructure.
An EC2 Ubuntu server is launched with a public IP address.
A security group allows HTTP traffic and restricts SSH access to an approved IP address.
Ansible connects to the EC2 instance using SSH.
Ansible installs and enables Nginx.
Ansible deploys the custom website.
The website is verified using a browser and an HTTP response check.
Technologies
AWS EC2
Terraform
Ansible
Ubuntu Linux
Nginx
SSH
Git and GitHub
Repository Structure
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
### Evidence
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

## Ansible Configuration Management

This project uses Ansible to configure an existing Ubuntu EC2 instance and deploy a custom Nginx website.

### Ansible project structure

```text
ansible/
├── ansible.cfg
├── files/
│   └── index.html
├── group_vars/
│   └── web/
│       ├── vars.yml
│       └── vault.yml
├── playbooks/
│   └── site.yml
├── roles/
│   ├── common/
│   │   ├── defaults/main.yml
│   │   └── tasks/main.yml
│   └── nginx/
│       ├── defaults/main.yml
│       ├── handlers/main.yml
│       ├── tasks/main.yml
│       └── templates/deployment.env.j2
└── inventory.ini.example

### Configuration management
The deployment uses two reusable Ansible roles:
- Common: updates the APT package cache and installs common system utilities.
- Nginx: installs and configures Nginx, deploys the custom website, manages application secret configuration and ensures the service is enabled and running.
The Nginx role uses a handler to restart the service when relevant configuration changes occur. Its secret configuration tasks also use Ansible block, rescue and always error handling.
### Secrets management with Ansible Vault
Sensitive application configuration is encrypted using Ansible Vault.

The encrypted variables are stored in:

ansible/group_vars/web/vault.yml

The Vault password must be kept private and must never be committed to Git. Commands use the interactive --ask-vault-pass option rather than a committed password file.

To create or update the encrypted variables file:
ansible-vault create group_vars/web/vault.yml


The deployment template writes the encrypted variable to a root-owned environment file on the EC2 instance with restrictive permissions (0600).

The token in this project demonstrates secure secret delivery. The static website does not currently consume this token.
### Running the deployment
First, configure your local inventory using the example file:
cp inventory.ini.example inventory.ini


Edit inventory.ini with your EC2 public IP and local SSH private key path. Do not commit this live inventory file.

Run the following commands from the ansible/ directory.

Check connectivity:
ansible web -m ping --ask-vault-pass


Validate playbook syntax:
ansible-playbook --syntax-check --ask-vault-pass playbooks/site.yml


Preview changes without applying them:
ansible-playbook --check --ask-vault-pass playbooks/site.yml


Apply the deployment:
ansible-playbook --ask-vault-pass playbooks/site.yml


Run the deployment again to verify idempotency:
ansible-playbook --ask-vault-pass playbooks/site.yml


Verify the deployed secret file permissions:
ansible web -b -m command -a "stat -c '%U:%G %a %n' /etc/ansible-nginx/deployment.env" --ask-vault-pass


Verify the website responds over HTTP:
curl -I http://YOUR_EC2_PUBLIC_IP


A successful deployment should return an HTTP 200 response. A second Ansible deployment should report no changes when the configuration is already converged.
### Security considerations
- Live inventory files and SSH private keys must remain outside version control.
- Terraform state, plan files and variable files containing sensitive information must not be committed.
- Ansible Vault encrypts sensitive variables before they are stored in the repository.
- The Vault password must be managed securely outside the repository.
- The deployed environment file is owned by root and uses file permission 0600.
### Evidence
Deployment evidence and screenshots are maintained in docs/evidence/.


## Environment-specific Ansible configuration

The project supports separate development and production inventories while reusing the same Ansible roles and deployment playbook.

```text
ansible/inventories/
├── dev/
│   ├── hosts.ini
│   └── group_vars/
│       └── dev_web.yml
└── prod/
    ├── hosts.ini
    └── group_vars/
        └── prod_web.yml


Both inventories use the parent web group, with separate child groups and environment-specific variables.
Deploy to development
Configure the development inventory with valid development connection details, then run from the ansible/ directory:
ansible-playbook -i inventories/dev/hosts.ini --ask-vault-pass playbooks/site.yml


Deploy to production
Configure the production inventory with valid production connection details, then run:
ansible-playbook -i inventories/prod/hosts.ini --ask-vault-pass playbooks/site.yml


The same roles and playbook are reused in both environments. Environment-specific settings are maintained separately. The encrypted Vault variables remain centrally managed under group_vars/web/.

Do not use placeholder inventory addresses for deployment. Keep real inventory credentials and SSH private keys out of version control.

## Advanced Ansible configuration

The Nginx role includes configuration-validation and graceful-reload handlers.

When an Nginx package change notifies the handler, Ansible runs `nginx -t` before reloading the service. Static website content updates do not trigger an unnecessary Nginx reload.

### Dynamic application configuration

The Jinja2 `deployment.env.j2` template renders environment-specific settings, including:

- Application environment
- Debug mode
- Application log level
- Application base URL
- Encrypted API token from Ansible Vault

Development and production settings are maintained independently under their respective inventory `group_vars` directories.

The rendered application environment file uses restricted file permissions. The API token is excluded from Ansible task output using `no_log`.

### SSH connection configuration

The inventory example includes:

- Explicit SSH connection and private-key settings
- Python interpreter configuration
- Connection timeout
- Privilege escalation through sudo
- SSH keepalive settings
- SSH connection persistence configured in `ansible.cfg`

These settings improve connection reliability while preserving SSH host-key checking.

### Validation

Validate the playbook:

```bash
cd ansible
ansible-playbook --syntax-check --ask-vault-pass playbooks/site.yml


Validate development and production inventory variables:
ansible-inventory -i inventories/dev/hosts.ini -i inventories/prod/hosts.ini --list --ask-vault-pass


The development and production template rendering checks can be performed locally without deploying to EC2.
EOF

echo "===== SERVICE MODULE ====="
ansible-doc -t module ansible.builtin.service >/dev/null && echo "Service module available"

echo "===== PATCH VALIDATION ====="
git diff --check || exit 1

echo "===== CHANGE SUMMARY ====="
git diff --stat

echo "===== CURRENT BRANCH ====="
git branch --show-current

echo "===== WORKING TREE ====="
git status --short
