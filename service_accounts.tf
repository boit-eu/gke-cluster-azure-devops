# Create namespace if it doesn't exist (optional)
resource "kubernetes_namespace" "deployment_namespace" {
  metadata {
    name = var.namespace
  }
}

# Service account for GKE nodes
resource "google_service_account" "gke_node_sa" {
  account_id   = "${var.cluster_name}-node-sa"
  display_name = "GKE Node Service Account"
}

# Google Service Account for Workload Identity
resource "google_service_account" "k8s_deploy_sa" {
  account_id   = "k8s-deploy-sa"
  display_name = "Kubernetes Deployment Service Account"
  description  = "Service account for deploying pods in development namespace"
}

# Create Kubernetes Service Account
resource "kubernetes_service_account" "deploy_sa" {
  metadata {
    name      = var.service_account_name
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name"       = var.service_account_name
      "app.kubernetes.io/managed-by" = "opentofu"
    }
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.k8s_deploy_sa.email
    }
  }

  depends_on = [kubernetes_namespace.deployment_namespace]
}

# Bind Google Service Account to Kubernetes Service Account
resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = google_service_account.k8s_deploy_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${kubernetes_namespace.deployment_namespace.metadata[0].name}/${kubernetes_service_account.deploy_sa.metadata[0].name}]"
  ]
}

# Grant necessary permissions to the deployment service account
resource "google_project_iam_member" "deploy_sa_permissions" {
  for_each = toset([
    "roles/container.developer",
    "roles/container.viewer",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.k8s_deploy_sa.email}"
}

# Create a role for pod deployment in the development namespace
resource "kubernetes_role" "pod_deployer" {
  metadata {
    namespace = kubernetes_namespace.deployment_namespace.metadata[0].name
    name      = "pod-deployer"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "configmaps", "secrets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = [""]
    resources  = ["services", "nodes", "namespaces"]
    verbs      = ["get", "list", "watch"]
  }
}

# Bind the role to the service account
resource "kubernetes_role_binding" "pod_deployer_binding" {
  metadata {
    name      = "pod-deployer-binding"
    namespace = kubernetes_namespace.deployment_namespace.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.pod_deployer.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.deploy_sa.metadata[0].name
    namespace = kubernetes_namespace.deployment_namespace.metadata[0].name
  }
}

# Create ClusterRole with pod deployment permissions
resource "kubernetes_cluster_role" "pod_deployer_cluster_role" {
  metadata {
    name = "${var.service_account_name}-role"
    labels = {
      "app.kubernetes.io/name"       = "${var.service_account_name}-role"
      "app.kubernetes.io/managed-by" = "opentofu"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log", "pods/status"]
    verbs      = ["create", "get", "list", "watch", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets"]
    verbs      = ["create", "get", "list", "watch", "update", "patch", "delete"]
  }

  rule {
    api_groups = [""]
    resources  = ["services", "configmaps", "secrets"]
    verbs      = ["create", "get", "list", "watch", "update", "patch", "delete"]
  }

  rule {
    api_groups = [""]
    resources  = ["events"]
    verbs      = ["get", "list", "watch"]
  }
}

# Create ClusterRoleBinding
resource "kubernetes_cluster_role_binding" "pod_deployer_cr_binding" {
  metadata {
    name = "${var.service_account_name}-binding"
    labels = {
      "app.kubernetes.io/name"       = "${var.service_account_name}-binding"
      "app.kubernetes.io/managed-by" = "opentofu"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.pod_deployer_cluster_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.deploy_sa.metadata[0].name
    namespace = var.namespace
  }
}
