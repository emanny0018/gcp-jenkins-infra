terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

data "google_compute_network" "vpc" {
  name = var.network_name
}

data "google_compute_subnetwork" "subnet" {
  name   = var.subnet_name
  region = var.region
}

# ---------------- Managed Instance Groups (one per service) ----------------
module "mig" {
  for_each = var.services
  source   = "./modules/mig"

  project_id = var.project_id
  region     = var.region

  # service name becomes base resource name: orders, payments, users, inventory, gateway
  name = each.key

  machine_type = each.value.machine_type
  min_replicas = each.value.min
  max_replicas = each.value.max

  network_self_link    = data.google_compute_network.vpc.self_link
  subnetwork_self_link = data.google_compute_subnetwork.subnet.self_link
}

# ---------------- Load Balancer (HTTP) ----------------

# Single LB health check (always ON)
resource "google_compute_health_check" "lb_hc_on" {
  name = "microservices-lb-hc"

  http_health_check {
    port         = 8080
    request_path = "/"
  }
}

# One backend service per service
resource "google_compute_backend_service" "backend" {
  for_each              = var.services
  name                  = "${each.key}-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.lb_hc_on.self_link]

  backend {
    group = module.mig[each.key].instance_group
  }
}

# URL map with path-based routing
resource "google_compute_url_map" "tomcat_map" {
  name = "microservices-urlmap"

  # default route if someone hits /
  default_service = google_compute_backend_service.backend["gateway"].self_link

  host_rule {
    hosts        = ["*"]
    path_matcher = "services"
  }

  path_matcher {
    name            = "services"
    default_service = google_compute_backend_service.backend["gateway"].self_link

    dynamic "path_rule" {
      for_each = var.services
      content {
        paths   = [path_rule.value.path]
        service = google_compute_backend_service.backend[path_rule.key].self_link
      }
    }
  }
}

resource "google_compute_target_http_proxy" "tomcat_proxy" {
  name    = "microservices-http-proxy"
  url_map = google_compute_url_map.tomcat_map.self_link
}

resource "google_compute_global_forwarding_rule" "tomcat_fwd" {
  name                  = "microservices-http-fr"
  load_balancing_scheme = "EXTERNAL"
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.tomcat_proxy.self_link
}
