variable "project_id" {
  type        = string
  description = "GCP project id"
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "zone" {
  type        = string
  description = "GCP zone (used only if needed)"
}

variable "instance_name" {
  type        = string
  description = "Base name for resources"
}

variable "machine_type" {
  type        = string
  description = "GCE machine type for instances"
  default     = "e2-medium"
}

variable "min_replicas" {
  type        = number
  description = "Minimum number of instances in the MIG"
  default     = 1
}

variable "max_replicas" {
  type        = number
  description = "Maximum number of instances in the MIG"
  default     = 2
}

variable "network_name" {
  type        = string
  description = "VPC network name"
  default     = "default"
}
variable "artifact_bucket" {
  type        = string
  description = "GCS bucket that stores WAR artifacts"
}

variable "services" {
  description = "Microservices definitions"
  type = map(object({
    path         = string
    min          = number
    max          = number
    machine_type = string
    war_object   = string
  }))
}

variable "subnet_name" {
  type        = string
  description = "Subnet name"
  default     = "default"
}
