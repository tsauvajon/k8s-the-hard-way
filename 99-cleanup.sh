terraform destroy infra # Networks, instances
gsutil rb gs://${CLOUDSDK_CORE_PROJECT}_tf-state/ # Terraform state bucket
gcloud iam service-accounts delete terraform  # Terraform Service account
gcloud services disable cloudresourcemanager.googleapis.com # APIs
gcloud services disable iam.googleapis.com # APIs
gcloud services disable compute.googleapis.com # APIs
gcloud projects delete ${CLOUDSDK_CORE_PROJECT} # Project
