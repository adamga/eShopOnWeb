#!/bin/bash

# Set the AKS cluster name and resource group
AKS_CLUSTER_NAME=$1
RESOURCE_GROUP=$2

# Set the release name and chart path
#RELEASE_NAME=$3
#CHART_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/webhelm/eshopwebhelm.yaml"

# Set the values for the variables
##SERVICE_PORT=$5

# Connect to the AKS cluster
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME

kubectl apply -f ./appdeploy.yaml 
# Deploy the chart
#helm install $RELEASE_NAME --generate-name --set containerPort=$CONTAINER_PORT,servicePort=$SERVICE_PORT