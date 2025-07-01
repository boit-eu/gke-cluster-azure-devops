# Outputs

# output "kubernetes_namespace" {
#   description = "Development namespace"
#   value       = kubernetes_namespace.deployment_namespace.metadata[0].name
# }

output "service_account_name" {
  description = "Kubernetes service account name"
  value       = kubernetes_service_account.deploy_sa.metadata[0].name
}

output "service_account_email" {
  description = "Google service account email"
  value       = google_service_account.k8s_deploy_sa.email
}

output "get_credentials_command" {
  description = "Command to get cluster credentials"
  value       = "gcloud container clusters get-credentials ${var.cluster_name} --region ${var.cluster_location} --project ${var.project_id}"
}
