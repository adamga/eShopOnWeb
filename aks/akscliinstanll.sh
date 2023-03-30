#!/bin/bash

# Set the AKS cluster name and resource group
AKS_CLUSTER_NAME=$1
RESOURCE_GROUP=$2

# Set the release name and chart path
RELEASE_NAME=$3
CHART_PATH=$4

# Set the values for the variables
IMAGE_NAME=$5
CONTAINER_PORT=$6
SERVICE_PORT=$7

# Connect to the AKS cluster
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME

# Deploy the chart
helm install $RELEASE_NAME $CHART_PATH --set imageName=$IMAGE_NAME,containerPort=$CONTAINER_PORT,servicePort=$SERVICE_PORT