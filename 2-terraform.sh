# Run Terraform from the infra folder
# https://github.com/hashicorp/terraform/issues/17300#issuecomment-364142374
cd infra

# Init Terraform with a remote backend
terraform init \
    -backend-config="bucket=${TF_VAR_project}_tf-state" \
    -backend-config="credentials=${TF_VAR_creds}"

terraform plan -out infra.plan
terraform apply "infra.plan"
