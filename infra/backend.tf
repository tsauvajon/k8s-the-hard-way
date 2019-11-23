data "terraform_remote_state" "state" {
  backend = "gcs"
  config = {
    bucket      = "${var.project}_tf-state"
    credentials = var.creds
  }
}
