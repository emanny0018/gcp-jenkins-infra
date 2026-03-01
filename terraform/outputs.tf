output "lb_ip" {
  description = "Public IP of the shared HTTP Load Balancer"
  value       = google_compute_global_forwarding_rule.tomcat_fwd.ip_address
}

output "instance_groups" {
  description = "Instance group URL per service"
  value       = { for svc, m in module.mig : svc => m.instance_group }
}

output "mig_names" {
  description = "MIG name per service"
  value       = { for svc, m in module.mig : svc => m.mig_name }
}

output "mig_autoheal_health_checks" {
  description = "MIG autohealing health check self_link per service"
  value       = { for svc, m in module.mig : svc => m.health_check }
}

output "tomcat_tags" {
  description = "Network tag applied to instances per service"
  value       = { for svc, m in module.mig : svc => m.tomcat_tag }
}

output "artifact_bucket" {
  description = "GCS bucket holding WAR artifacts"
  value       = var.artifact_bucket
}

output "war_objects" {
  description = "GCS object path per service (object path inside artifact_bucket)"
  value       = { for svc, cfg in var.services : svc => cfg.war_object }
}
