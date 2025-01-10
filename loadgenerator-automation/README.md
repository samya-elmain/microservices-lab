## Steps to Set Up

### 1. Generate a GCP Service Account Key

# 1. Set your project ID
PROJECT_ID="your-gcp-project-id"

# 2. Create a service account
gcloud iam service-accounts create terraform-service-account \
  --description="Service account for Terraform" \
  --display-name="Terraform Service Account" \
  --project="$PROJECT_ID"

# 3. Assign the "Compute Admin" role to the service account
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:terraform-service-account@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/compute.admin"

# 4. Create and download the JSON key file
gcloud iam service-accounts keys create service-account.json \
  --iam-account="terraform-service-account@$PROJECT_ID.iam.gserviceaccount.com"

### 2. Generate SSH Keys

Generate an SSH key pair to access the VM:

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/gcp_vm_key
```

- The public key is stored in `~/.ssh/gcp_vm_key.pub`. You will use this key in the Terraform configuration.

### 3. Update Terraform Variables

Create a `terraform.tfvars` file and add your values:

```hcl
project_id     = "your-gcp-project-id"
region         = "us-central1"
zone           = "us-central1-a"
instance_name  = "gcp-vm-instance"
machine_type   = "e2-medium"
ssh_public_key = "$(cat ~/.ssh/gcp_vm_key.pub)"
```

### 4. Deploy the Infrastructure with Terraform

Initialize Terraform and apply the configuration:

```bash
terraform init
terraform apply
```

Confirm the changes when prompted. After the deployment is complete, Terraform will output the external IP address of the VM.

### 5. Configure the VM with Ansible

# Replace <external-ip-address> with the actual IP address output by Terraform in inventory.ini
[gcp-vm]
<external-ip-address> ansible_user=your-ssh-username ansible_ssh_private_key_file=~/.ssh/gcp_vm_key
```

Run the Ansible playbook:

```bash
ansible-playbook -i inventory playbook.yaml
```

### 6. Clean Up

To delete the resources created by Terraform:

```bash
terraform destroy
```

## File Descriptions

- **`main.tf`**: Terraform configuration file for creating a GCP VM.
- **`variables.tf`**: Variables used in the Terraform configuration.
- **`outputs.tf`**: Outputs the external IP of the VM.
- **`playbook.yaml`**: Ansible playbook to install Docker, add the user to the Docker group, pull a Docker image, and run a container.
- **`inventory`**: Ansible inventory file to define the target VM.

