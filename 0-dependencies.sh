set -a; source .env; set +a

brew install cfssl

curl -o kubectl https://storage.googleapis.com/kubernetes-release/release/v1.15.3/bin/darwin/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
