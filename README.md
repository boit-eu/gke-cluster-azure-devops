# gke-cluster-azure-devops
Google Kubernetes Engine Cluster with Service Account for Connection from Azure DevOps

## Requirements

* asdf

Create a terraform.tfvars file with your data

```yaml
project_id = "my-projectid-1234"
cluster_name = "my-gke-cluster"
cluster_location = "europe-west4-b"  # or your cluster's zone/region
service_account_name = "pod-deployer"  # optional, defaults to "pod-deployer"
namespace = "deployment"     # optional, defaults to "default"
```

## Usage

```bash
# Install all required packages
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

## Azure DevOps Config

Configure the Pipeline Code from ./azure-pipelines/azure-pipeline-hello-world.yml for you Azure DevOps Project.

You have to configure the following Variables:

```
GCP_SERVICE_ACCOUNT_KEY # as secret value
GCP_PROJECT_ID          # your google project id
GKE_CLUSTER_NAME        # your google gke cluster name
GKE_CLUSTER_REGION      # your region
```

To get the GCP_SERVICE_ACCOUNT_KEY you have to run this command:

```bash
# Create and download service account key
gcloud iam service-accounts keys create azure-devops-key.json \
    --iam-account=k8s-deploy-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com
```
