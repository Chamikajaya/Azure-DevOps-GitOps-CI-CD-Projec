#!/bin/bash


SERVICE_NAME=$1
IMAGE_TAG=$2
ACR_REGISTRY=$3

if [ -z "$SERVICE_NAME" ] || [ -z "$IMAGE_TAG" ] || [ -z "$ACR_REGISTRY" ]; then
    echo "Error: Missing required arguments"
    echo "Usage: ./update-manifest.sh <service-name> <image-tag> <acr-registry>"
    exit 1
fi

MANIFEST_FILE="k8s-specifications/${SERVICE_NAME}-deployment.yaml"

if [ ! -f "$MANIFEST_FILE" ]; then
    echo "Error: Manifest file not found: $MANIFEST_FILE"
    exit 1
fi

# Update the image tag in the deployment manifest
# Replace the image line with new ACR image and tag
sed -i "s|image: .*|image: ${ACR_REGISTRY}/${SERVICE_NAME}service:${IMAGE_TAG}|g" "$MANIFEST_FILE"

echo "Updated $MANIFEST_FILE with image: ${ACR_REGISTRY}/${SERVICE_NAME}service:${IMAGE_TAG}"

# Configure git
git config --global user.email "azure-pipeline@dev.azure.com"
git config --global user.name "Azure Pipeline"

# Commit and push changes
git add "$MANIFEST_FILE"
git commit -m "Update ${SERVICE_NAME} image tag to ${IMAGE_TAG} [skip ci]"
git push origin HEAD:main

echo "Successfully pushed manifest update to repository"