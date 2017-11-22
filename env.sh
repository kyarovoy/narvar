#!/bin/bash

# Install requirements
pip install --upgrade --ignore-installed -r requirements.txt

# Install Terraform
RELEASE="0.11.0"
wget -c "https://releases.hashicorp.com/terraform/$RELEASE/terraform_${RELEASE}_darwin_amd64.zip" -P /tmp
unzip -u /tmp/terraform_${RELEASE}_darwin_amd64.zip -d /usr/local/bin

# Install external Ansible Galaxy roles
ansible-galaxy install -r requirements.yml --roles-path roles
