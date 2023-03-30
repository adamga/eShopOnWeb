# Set the AKS cluster name and resource group
$aksClusterName = "adamfoo"
$resourceGroup = "myResourceGroup"

# Set the release name and chart path
$releaseName = "my-release"
$chartPath = "path/to/chart"

# Set the values for the variables
$imageName = "my-image"
$containerPort = 80
$servicePort = 80

# Connect to the AKS cluster
az aks get-credentials --resource-group $resourceGroup --name $aksClusterName

# Deploy the chart
helm install $releaseName $chartPath --set imageName=$imageName,containerPort=$containerPort,servicePort=$servicePort



CLI Only


# Set the AKS cluster name and resource group
AKS_CLUSTER_NAME="adamfoo"
RESOURCE_GROUP="myResourceGroup"

# Set the release name and chart path
RELEASE_NAME="my-release"
CHART_PATH="path/to/chart"

# Set the values for the variables
IMAGE_NAME="my-image"
CONTAINER_PORT=80
SERVICE_PORT=80

# Connect to the AKS cluster
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER_NAME

# Deploy the chart
helm install $RELEASE_NAME $CHART_PATH --set imageName=$IMAGE_NAME,containerPort=$CONTAINER_PORT,servicePort=$SERVICE_PORT