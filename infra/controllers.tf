# Cannot do a resource for_each yet in 0.12:
# https://www.hashicorp.com/blog/hashicorp-terraform-0-12-preview-for-and-for-each/#resource-for_each
resource "google_compute_instance" "controller_0" {
  name         = "controller-0"
  zone         = var.zone
  machine_type = "n1-standard-1"

  can_ip_forward = true
  tags           = ["k8s", "controller"]

  network_interface {
    network_ip = "10.240.0.10"
    subnetwork = google_compute_subnetwork.k8s.self_link
  }

  service_account {
    scopes = [
      "compute-rw",
      "storage-ro",
      "service-management",
      "service-control",
      "logging-write",
      "monitoring",
    ]
  }

  boot_disk {
    initialize_params {
      size = 40 # Gb
      type = "pd-standard"

      # format: {project}/{image}
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }
}


resource "google_compute_instance" "controller_1" {
  name         = "controller-1"
  zone         = var.zone
  machine_type = "n1-standard-1"

  can_ip_forward = true
  tags           = ["k8s", "controller"]

  network_interface {
    network_ip = "10.240.0.11"
    subnetwork = google_compute_subnetwork.k8s.self_link
  }

  service_account {
    scopes = [
      "compute-rw",
      "storage-ro",
      "service-management",
      "service-control",
      "logging-write",
      "monitoring",
    ]
  }

  boot_disk {
    initialize_params {
      size = 40
      type = "pd-standard"

      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }
}


resource "google_compute_instance" "controller_2" {
  name         = "controller-2"
  zone         = var.zone
  machine_type = "n1-standard-1"

  can_ip_forward = true
  tags           = ["k8s", "controller"]

  network_interface {
    network_ip = "10.240.0.12"
    subnetwork = google_compute_subnetwork.k8s.self_link
  }

  service_account {
    scopes = [
      "compute-rw",
      "storage-ro",
      "service-management",
      "service-control",
      "logging-write",
      "monitoring",
    ]
  }

  boot_disk {
    initialize_params {
      size = 40
      type = "pd-standard"

      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }
}
