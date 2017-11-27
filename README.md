# narvar

Prepare environment
```
git clone https://github.com/kyarovoy/narvar
cd narvar
sudo ./env.sh
```

Define AWS credentials by creating terraform.tfvars file with the following content:
```
aws_access_key = "<access_key>"
aws_secret_key = "<secret_key>"
```

Create infrastructure
```
sudo terraform init
sudo terraform apply
```

Enforce configuration using Ansible
```
ansible-playbook -i inventory narvar.yaml
```
