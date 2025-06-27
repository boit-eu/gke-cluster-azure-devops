# gke-cluster-azure-devops
Google Kubernetes Engine Cluster with Service Account for Connection from Azure DevOps

# Requirements

* asdf

Create a terraform.tfvars file with your data

```yaml
project_id = "my-projectid-1234"
cluster_name = "my-gke-cluster"
cluster_location = "europe-west4-b"  # or your cluster's zone/region
service_account_name = "pod-deployer"  # optional, defaults to "pod-deployer"
namespace = "deployment"     # optional, defaults to "default"
```

# Usage

```bash
# Installa all required packages
asdf install

# connect to existing GKE cluster
gcloud container clusters get-credentials my-gke-cluster --region europe-west4-b --project my-projectid-1234

# Initialize Tofu
tofu init

# Check the status of your deployment
tofu plan

# Apply all configurations
tofu apply
```
