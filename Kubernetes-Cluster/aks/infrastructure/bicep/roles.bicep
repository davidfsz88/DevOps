param aksAgicId string
param aksId string
param env string
param name string
param aksKubeletId string
//ROLES
@description('This is the built-in Contributor role')
resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2020-08-01-preview' existing = {
  scope: subscription()
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
}
@description('This is the built-in Network-Contributor role')
resource networkContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2020-08-01-preview' existing = {
  scope: subscription()
  name: '4d97b98b-1d4f-4787-a291-c67834d212e7'
}

@description('This is the built-in Managed Identity Operator Contributor role')
resource identityManagementRoleDefinition 'Microsoft.Authorization/roleDefinitions@2020-08-01-preview' existing = {
  scope: subscription()
  name: 'f1a07417-d97a-45cb-824c-7a7467783830'
}



//IDENTITIES
resource agwIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'sp-${name}-agic-${env}'
  location: resourceGroup().location
}
// usuario puede asignarle los roles al aks y al agic

//ROLE ASSIGNMENTS
// pod agic 
resource aksfix 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(name, resourceGroup().id, 'aksfix', 'Contributor', env)
  scope: resourceGroup()
  properties: {
    description: 'fixes aks cross resource group principal permissions fix gor agic rule dinamic creation'
    principalId: aksAgicId
    principalType: 'ServicePrincipal'
    roleDefinitionId: contributorRoleDefinition.id
  }
}

resource aksLbRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(name, resourceGroup().id, 'aksLbRole', 'NetworkContributor', env)
  scope: resourceGroup()
  properties: {
    description: 'allows aks to create LBS'
    principalId: aksId
    principalType: 'ServicePrincipal'
    roleDefinitionId: networkContributorRoleDefinition.id
  }
}

//todo asign to agw by any means
resource kvPull 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(name, resourceGroup().id, 'kv', 'kvPull', 'kvPull', env)
  scope: resourceGroup()
  properties: {
    description: 'Assign kvPull role to AGW thi is for internal ssl handshakes'
    principalId: agwIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: identityManagementRoleDefinition.id
  }
}



//ESPECIAL ASIGNATIONS
module especialrole 'acr.bicep' = {
  name: 'central-acr-deploy'
  scope: resourceGroup('7f380419-f712-44df-9e32-2058d40efbb6', 'rg-common')
  params: {
    name: name
    env: env
    kubeletId: aksKubeletId
  }
}
