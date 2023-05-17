param kubeletId string
param name string
param env string

@description('This is the built-in ACR Pull role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#acrpull')
resource pullRoleDefinition 'Microsoft.Authorization/roleDefinitions@2020-08-01-preview' existing = {
  scope: subscription()
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
}

resource acr 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' existing = {
  name: 'Institution'
}

resource acrPull 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(name, resourceGroup().id, 'acr', 'acrPull', 'acrPull', env)
  scope: acr
  properties: {
    description: 'Assign AcrPull role to AKS'
    principalId: kubeletId
    principalType: 'ServicePrincipal'
    roleDefinitionId: pullRoleDefinition.id
  }
}
