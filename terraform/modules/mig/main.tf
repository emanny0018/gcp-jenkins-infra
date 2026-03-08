resource "google_compute_firewall" "allow_tomcat_8080" {
  name    = "${var.name}-allow-8080"
  network = var.network_self_link

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]

  target_tags = ["${var.name}-tomcat"]
}

resource "google_compute_health_check" "http" {
  name = "${var.name}-hc"

  http_health_check {
    port         = 8080
    request_path = "/"
  }
}

resource "google_compute_instance_template" "tpl" {
  name_prefix  = "${var.name}-tpl-"
  machine_type = var.machine_type

  disk {
    boot         = true
    auto_delete  = true
    source_image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
    disk_size_gb = 20
    disk_type    = "pd-balanced"
  }

  tags = ["${var.name}-tomcat"]

  network_interface {
    network    = var.network_self_link
    subnetwork = var.subnetwork_self_link

    # Public IP so Jenkins / Ansible can reach instances
    access_config {}
  }

  # SERVICE ACCOUNT ATTACHED TO VM
  service_account {
    email  = "manny-563@flooid-488720.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  # marker file so we know instance booted
  metadata_startup_script = <<-EOT
    #!/bin/bash
    echo "booted" > /tmp/booted.txt
  EOT

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }
}

resource "google_compute_region_instance_group_manager" "mig" {
  name   = "${var.name}-mig"
  region = var.region

  base_instance_name = var.name

  version {
    instance_template = google_compute_instance_template.tpl.self_link
  }

  named_port {
    name = "http"
    port = 8080
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.http.self_link
    initial_delay_sec = 120
  }

  target_size = var.min_replicas
}

resource "google_compute_region_autoscaler" "as" {
  name   = "${var.name}-as"
  region = var.region
  target = google_compute_region_instance_group_manager.mig.self_link

  autoscaling_policy {
    min_replicas    = var.min_replicas
    max_replicas    = var.max_replicas
    cooldown_period = 60

    cpu_utilization {
      target = 0.80
    }
  }
}
