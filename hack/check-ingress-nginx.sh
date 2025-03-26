#!/bin/bash

# Check if kubectl and gcloud are installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl could not be found. Please install it."
    exit 1
fi

if ! command -v gcloud &> /dev/null; then
    echo "gcloud could not be found. Please install it and configure it to connect to your GCP project."
    exit 1
fi

# Get the current project ID
PROJECT_ID=$(gcloud config get-value project)
if [ -z "$PROJECT_ID" ]; then
    echo "GCP project ID is not configured. Please run 'gcloud config set project <YOUR_PROJECT_ID>'."
    exit 1
fi

echo "Listing GKE clusters in project: $PROJECT_ID..."
echo "----------------------------------------------------"

# Get all GKE cluster names in the current project
CLUSTER_NAMES=$(gcloud container clusters list --project="$PROJECT_ID" --format='value(name)')

# Iterate through each cluster
for CLUSTER_NAME in $CLUSTER_NAMES; do
    echo "Checking cluster: $CLUSTER_NAME..."

    # Get the kubeconfig for the current cluster
    gcloud container clusters get-credentials "$CLUSTER_NAME" --project="$PROJECT_ID" --region=$(gcloud config get-value compute/region --format='default' 2>/dev/null) --zone=$(gcloud config get-value compute/zone --format='default' 2>/dev/null) &> /dev/null

    # Check if ingress-nginx controller deployment exists in any namespace
    INGRESS_NGINX_DEPLOYMENT=$(kubectl get deployments --all-namespaces -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name --no-headers | grep "ingress-nginx-controller")

    if [ -n "$INGRESS_NGINX_DEPLOYMENT" ]; then
        echo "  - Found ingress-nginx controller deployment(s):"
        echo "$INGRESS_NGINX_DEPLOYMENT" | sed 's/^\s*//' | sed 's/\s\+/\t/'
    else
        echo "  - ingress-nginx controller not found."
    fi
    echo "----------------------------------------------------"
done

echo "Finished checking all GKE clusters."