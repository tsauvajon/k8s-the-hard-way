resource "google_compute_network" "k8s" {
  name                    = "k8s-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "k8s" {
  name          = "k8s-subnet"
  region        = var.region
  network       = google_compute_network.k8s.name
  ip_cidr_range = "10.240.0.0/24"
}

resource "google_compute_firewall" "internal" {
  name    = "k8s-allow-internal"
  network = google_compute_network.k8s.name

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }

  source_ranges = ["10.240.0.0/24", "10.200.0.0/16"]
}

resource "google_compute_firewall" "external" {
  name    = "k8s-allow-external"
  network = google_compute_network.k8s.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "6443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_address" "static_ip" {
  name   = "k8s-ip"
  region = var.region
}
