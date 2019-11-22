variable "project" {}
variable "billing_account" {}
variable "region" {}
variable "creds" {}

provider "google" {
  region      = var.region
  credentials = file(var.creds)

  version = "~> 3.0.0-beta.1"
}

module "project_services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "5.0.0"

  project_id = var.project
  activate_apis = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
  ]

  disable_services_on_destroy = true
  disable_dependent_services  = true
}
