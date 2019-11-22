provider "google" {
  region      = var.region
  credentials = file(var.creds)

  version = "~> 3.0.0-beta.1"
}
