param name string
param env string
resource logworkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: 'log-${name}-${env}'
  location: resourceGroup().location
}

output laworkspaceId string = logworkspace.id
