set -a; source .env; set +a


### Initial project Setup
gcloud init

gcloud projects create ${CLOUDSDK_CORE_PROJECT} --name=${CLOUDSDK_CORE_PROJECT}

gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable compute.googleapis.com

### Create a Terraform editor account
gcloud iam service-accounts create terraform \
  --display-name "Terraform editor account"

gcloud iam service-accounts keys create ${TF_VAR_creds} \
  --iam-account terraform@${CLOUDSDK_CORE_PROJECT}.iam.gserviceaccount.com

gcloud projects add-iam-policy-binding ${CLOUDSDK_CORE_PROJECT} \
  --member serviceAccount:terraform@${CLOUDSDK_CORE_PROJECT}.iam.gserviceaccount.com \
  --role roles/editor

gcloud projects add-iam-policy-binding ${CLOUDSDK_CORE_PROJECT} \
  --member serviceAccount:terraform@${CLOUDSDK_CORE_PROJECT}.iam.gserviceaccount.com \
  --role roles/storage.admin

### Create a bucket to store the Terraform state
# https://github.com/hashicorp/terraform/issues/18417#issuecomment-403603798
gsutil mb gs://${CLOUDSDK_CORE_PROJECT}_tf-state/
