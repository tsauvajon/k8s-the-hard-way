output "controller-0_name" {
  value       = google_compute_instance.controller_0.name
  description = "Name of the controller_0 instance"
}
output "controller-1_name" {
  value       = google_compute_instance.controller_1.name
  description = "Name of the controller_1 instance"
}
output "controller-2_name" {
  value       = google_compute_instance.controller_2.name
  description = "Name of the controller_2 instance"
}

output "worker-0_name" {
  value       = google_compute_instance.worker_0.name
  description = "Name of the worker_0 instance"
}
output "worker-1_name" {
  value       = google_compute_instance.worker_1.name
  description = "Name of the worker_1 instance"
}
output "worker-2_name" {
  value       = google_compute_instance.worker_2.name
  description = "Name of the worker_2 instance"
}

output "worker-0_internal_ip" {
  value       = google_compute_instance.worker_0.network_interface.0.network_ip
  description = "Internal IP of the worker_0 instance"
}
output "worker-1_internal_ip" {
  value       = google_compute_instance.worker_1.network_interface.0.network_ip
  description = "Internal IP of the worker_1 instance"
}
output "worker-2_internal_ip" {
  value       = google_compute_instance.worker_2.network_interface.0.network_ip
  description = "Internal IP of the worker_2 instance"
}

output "worker-0_external_ip" {
  value       = google_compute_instance.worker_0.network_interface.0.access_config.0.nat_ip
  description = "External IP of the worker_0 instance"
}
output "worker-1_external_ip" {
  value       = google_compute_instance.worker_1.network_interface.0.access_config.0.nat_ip
  description = "External IP of the worker_1 instance"
}
output "worker-2_external_ip" {
  value       = google_compute_instance.worker_2.network_interface.0.access_config.0.nat_ip
  description = "External IP of the worker_2 instance"
}

output "k8s_public_ip" {
  value       = google_compute_address.static_ip.address
  description = "Kubernetes public static IP address"
}
