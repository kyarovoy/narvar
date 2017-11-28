# narvar

### Overview

This repository demonstrates how to use modern DevOps toolchain to:
- define infrastructure as a code and provision it using Terraform (cloud provider is AWS in this example)
- enforce configuration using Ansible

### Instructions

1. Prepare your environment
```
git clone https://github.com/kyarovoy/narvar
cd narvar
sudo ./env.sh
```
This will clone current repo and install Terraform, Ansible and some additional dependencies.

2. (optional) [Register new AWS Free Tier account](https://aws.amazon.com/free/)
3. (optional) [Create a new IAM user with Administrator permisssions and create Access Key for this user](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html). You will receive Access Key and Secret Key.
4. In order to interact with AWS using Terraform - you will need to define your IAM user AWS credentials in a new terraform.tfvars in the following way:
```
# vim terraform.tfvars:

aws_access_key = "<access_key>"
aws_secret_key = "<secret_key>"
```
5. Provision infrastructure
```
sudo terraform init
sudo terraform apply
```
This will perform the following operations in us-east-1 AWS region:
- create a new VPC (10.0.0.0/16)
- create a new Gateway for this VPC
- create a Route to allow external Internet communications
- create a Security Group to allow certain incoming connections (SSH,HTTP,HTTPS,OpenVPN UDP/4300)
- create a new subnet (10.0.0.0/24)
- create a new keypair (based on ~/.ssh/id_rsa.pub file)
- create a new EC2 t2.micro instance (OS: CentOS 7)

All these default settings can easily be changed in [variables.tf](variables.tf) configuration file. 

6. Configure infrastructure using Ansible
```
ansible-playbook -i inventory narvar.yaml
```
This will apply Ansible roles to all nodes provisioned by Terraform.
By supplying "-i inventory" we are instructing Ansible to use [Terraform.PY dynamic inventory script](https://github.com/mantl/terraform.py), which builds host list by analyzing Terraform's .tfstate files 

Ansible roles:
- web: configures NginX web server (with or without SSL)
- webmon: installs cron job which monitors Disk and CPU usage and sends email notification if thresholds are met. [Monitoring script](roles/webmon/templates/monitor.sh.j2) is written in Python.
- webapp: deploys [modern webapp (Python 3.6, Flask) from GitHub repo](https://github.com/kyarovoy/narvar_webapp) in a separate virtualenv and places it behind NginX: (https://ec2-52-55-211-215.compute-1.amazonaws.com/webapp)
- vpn: configures OpenVPN server on port 4300

These Ansible roles depend on publicly available roles (Nginx, OpenVPN) from Ansible Galaxy to show how important is to avoid reinventing the wheel

#### Connecting to the node using OpenVPN

Ansible playbook configures OpenVPN server on EC2 instance provisioned by Terraform.
To connect to an existing live demo EC2 node (ec2-52-55-211-215.compute-1.amazonaws.com):
- Install OpenVPN client (e.g. TunnelBrick for MacOS X)
- Download [client config file](openvpn_configs/client1-test.ovpn)

If you are using provided Terraform files to create your own infrastructure from scratch, after running Ansible playbook you will find OpenVPN client config at: /etc/openvpn/client1-test.ovpn
