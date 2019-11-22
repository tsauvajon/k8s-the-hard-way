set -a; source .env; set +a

brew install cfssl

curl -o kubectl https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/darwin/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

curl -o terraform.zip https://releases.hashicorp.com/terraform/0.12.16/terraform_0.12.16_darwin_amd64.zip
unzip terraform.zip
rm terraform.zip
chmod +x terraform
sudo mv terraform /usr/local/bin
terraform -install-autocomplete
