variable "project_id" {
  type        = string
  description = "GCP project where resources will be created"
}

variable "region" {
  type        = string
  description = "Region for the Managed Instance Group"
}

variable "name" {
  type        = string
  description = "Base name used for all resources (template, MIG, autoscaler, health check)"
}

variable "machine_type" {
  type        = string
  description = "Machine type for instances in the MIG"
  default     = "e2-medium"
}

variable "min_replicas" {
  type        = number
  description = "Minimum number of instances the MIG keeps alive"
  default     = 1
}

variable "max_replicas" {
  type        = number
  description = "Maximum number of instances the MIG can scale to"
  default     = 2
}

variable "network_self_link" {
  type        = string
  description = "Self link of the VPC network"
}

variable "subnetwork_self_link" {
  type        = string
  description = "Self link of the subnet"
}
