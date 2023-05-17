

param($environment='dev',$resourceGroupName='rg-aks-controlplane-dev',$envFile="@../params/parameters.dev.json",$mainFile='../bicep/main.bicep')
$location = 'eastus'
"Printing azure cli version..."
az --version

Write-Output "Creating resource group $resourceGroupName in location $location...";
az group create --name $resourceGroupName --location $location

Write-Output "Initializing deployment";
az deployment group create -n 'main-deployment'  -g $resourceGroupName -f $mainFile -p  $envFile --verbose
