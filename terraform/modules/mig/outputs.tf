output "mig_name" {
  description = "Managed Instance Group Manager name"
  value       = google_compute_region_instance_group_manager.mig.name
}

output "mig_self_link" {
  description = "MIG self link"
  value       = google_compute_region_instance_group_manager.mig.self_link
}

output "instance_group" {
  description = "Underlying instance group URL"
  value       = google_compute_region_instance_group_manager.mig.instance_group
}

output "health_check" {
  description = "Health check self link used for autohealing"
  value       = google_compute_health_check.http.self_link
}

output "tomcat_tag" {
  description = "Network tag applied to MIG instances"
  value       = "${var.name}-tomcat"
}
