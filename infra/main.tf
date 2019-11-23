# https://www.terraform-best-practices.com/code-structure
provider "google" {
  region      = var.region
  credentials = file(var.creds)

  version = "~> 3.0.0-beta.1"
}
