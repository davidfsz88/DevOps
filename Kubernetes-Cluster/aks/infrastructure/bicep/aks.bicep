param k8sVersion string
param env string
param poolCount int
param poolVmSize string
param vnetSubnetID string
param clusterAdminGroupId string
//param appiWorkspaceName string
param applicationGatewayId string
//param appiWorkspaceNameRG string
param appiWorkspaceId string
param akslimits object
param name string
@description('DO NOT EXECUTE OVER EXISTING CLUSTER BY ANY MEANS')
resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  name: 'aks-core-${env}'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${name}-${env}'
    nodeResourceGroup: 'rg-${name}-nodes-${env}'
    kubernetesVersion: k8sVersion
    disableLocalAccounts: true
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: poolCount
        vmSize: poolVmSize
        osType: 'Linux'
        mode: 'System'
        enableAutoScaling: true
        maxCount: akslimits.max
        minCount: akslimits.min
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: vnetSubnetID
      }
    ]
    enableRBAC: true
    aadProfile: {
      adminGroupObjectIDs: [
        clusterAdminGroupId
      ]
      enableAzureRBAC: true
      managed: true
      tenantID: subscription().tenantId
    }
    networkProfile: {
      dockerBridgeCidr: '172.17.0.1/16'
      loadBalancerSku: 'standard'
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      serviceCidr: '10.0.0.0/16'
      dnsServiceIP: '10.0.0.10'
    }
    apiServerAccessProfile: {
      enablePrivateCluster: true
    }
    addonProfiles: {
      omsagent: {
        config: {
          logAnalyticsWorkspaceResourceID: appiWorkspaceId
        }
        enabled: true
      }
      // openServiceMesh: {
      //   enabled: true
      //   config: {}
      // }
      ingressApplicationGateway: {
        enabled: true
        config: {
          applicationGatewayId: applicationGatewayId
          effectiveApplicationGatewayId: applicationGatewayId
        }
      }
      azurepolicy: {
        enabled: true
      }
      azureKeyvaultSecretsProvider: {
        enabled: true
      }
    }
  }
}

// different rg from the node and master
output aksKubeletId string = aksCluster.properties.identityProfile.kubeletidentity.objectId
// worker nodes
output aksId string = aksCluster.identity.principalId
// internal pod agic
output aksAgicId string = aksCluster.properties.addonProfiles.ingressApplicationGateway.identity.objectId
