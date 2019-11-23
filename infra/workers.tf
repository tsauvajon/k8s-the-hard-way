# Cannot do a resource for_each yet in 0.12:
# https://www.hashicorp.com/blog/hashicorp-terraform-0-12-preview-for-and-for-each/#resource-for_each
resource "google_compute_instance" "worker_0" {
  name         = "worker-0"
  zone         = var.zone
  machine_type = "n1-standard-1"

  can_ip_forward = true
  tags           = ["k8s", "worker"]

  network_interface {
    network_ip = "10.240.0.20"
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

      # format: projects/{project}/global/images/{image}
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-1804-lts"
    }
  }

  metadata = {
    pod-cidr = "10.200.0.0/24"
  }
}


resource "google_compute_instance" "worker_1" {
  name         = "worker-1"
  zone         = var.zone
  machine_type = "n1-standard-1"

  can_ip_forward = true
  tags           = ["k8s", "worker"]

  network_interface {
    network_ip = "10.240.0.21"
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

      image = "projects/ubuntu-os-cloud/global/images/ubuntu-1804-lts"
    }
  }

  metadata = {
    pod-cidr = "10.200.0.0/24"
  }
}


resource "google_compute_instance" "worker_2" {
  name         = "worker-2"
  zone         = var.zone
  machine_type = "n1-standard-1"

  can_ip_forward = true
  tags           = ["k8s", "worker"]

  network_interface {
    network_ip = "10.240.0.22"
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

      image = "projects/ubuntu-os-cloud/global/images/ubuntu-1804-lts"
    }
  }

  metadata = {
    pod-cidr = "10.200.0.0/24"
  }
}
