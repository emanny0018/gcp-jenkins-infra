project_id   = "flooid-488720"
region       = "us-central1"
zone         = "us-central1-a"
artifact_bucket = "flooid-test"

instance_name = "tomcat-mig"
machine_type  = "e2-medium"

min_replicas = 1
max_replicas = 2

network_name = "default"
subnet_name  = "default"
services = {
  orders = {
    path         = "/orders/*"
    min          = 1
    max          = 2
    machine_type = "e2-medium"
    war_object   = "wars/orders.war"
  }
  payments = {
    path         = "/payments/*"
    min          = 1
    max          = 2
    machine_type = "e2-medium"
    war_object   = "wars/payments.war"
  }
  users = {
    path         = "/users/*"
    min          = 1
    max          = 2
    machine_type = "e2-medium"
    war_object   = "wars/users.war"
  }
  inventory = {
    path         = "/inventory/*"
    min          = 1
    max          = 2
    machine_type = "e2-medium"
    war_object   = "wars/inventory.war"
  }
  gateway = {
    path         = "/*"
    min          = 1
    max          = 2
    machine_type = "e2-medium"
    war_object   = "wars/gateway.war"
  }
}
