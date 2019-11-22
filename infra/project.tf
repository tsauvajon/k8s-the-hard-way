module "project_services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "5.0.0"

  project_id = var.project
  activate_apis = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
  ]

  disable_services_on_destroy = false
  disable_dependent_services  = false
}
