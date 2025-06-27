# Variables
variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "cluster_name" {
  description = "GKE Cluster name"
  type        = string
}

variable "cluster_location" {
  description = "GKE Cluster location (zone or region)"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the service account"
  type        = string
  default     = "default"
}

variable "service_account_name" {
  description = "Name of the Kubernetes service account"
  type        = string
  default     = "deploy-sa"
}