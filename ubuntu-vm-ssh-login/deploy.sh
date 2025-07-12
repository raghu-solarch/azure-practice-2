#!/bin/bash
set -e

KEY_FILE="my-ssh-key"
PEM_KEY_FILE="my-ssh-key.pem"
TF_VAR_ADMIN_USERNAME="learning"   # Update if your admin_username is different

# 1. Generate OpenSSH private key if it doesn't exist
if [ ! -f "$KEY_FILE" ]; then
  echo "Generating OpenSSH key pair..."
  ssh-keygen -t rsa -b 4096 -f $KEY_FILE -N ""
else
  echo "OpenSSH key already exists, reusing: $KEY_FILE"
fi

# 2. Export the public key for Terraform
export TF_VAR_public_ssh_key="$(cat ${KEY_FILE}.pub)"
export TF_VAR_admin_username="$TF_VAR_ADMIN_USERNAME"

# 3. Convert to classic PEM format if needed
if [ ! -f "$PEM_KEY_FILE" ]; then
  echo "Converting private key to PEM format for compatibility..."
  ssh-keygen -p -m PEM -f $KEY_FILE -N "" -P ""
  cp $KEY_FILE $PEM_KEY_FILE
else
  echo "PEM key already exists, reusing: $PEM_KEY_FILE"
fi

# 4. Run Terraform
terraform init
terraform apply -auto-approve

VM_IP=$(terraform output -raw public_ip)
echo ""
echo "=========================================================="
echo "VM Provisioned!"
echo "SSH into your VM using:"
echo ""
echo "Linux/macOS/WSL/Native SSH:"
echo "ssh -i $KEY_FILE $TF_VAR_ADMIN_USERNAME@$VM_IP"
echo ""
echo "MobaXterm/WinSCP/Putty or tools requiring PEM format:"
echo "ssh -i $PEM_KEY_FILE $TF_VAR_ADMIN_USERNAME@$VM_IP"
echo ""
echo "You can import either key into your SSH client as needed."
echo "=========================================================="
