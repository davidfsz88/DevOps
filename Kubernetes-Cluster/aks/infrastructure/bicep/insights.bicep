param name string
param workspaceName string
param workspaceGroupName string
param environment string = 'dev'
param kind string

resource insights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-${name}-${environment}'
  location: resourceGroup().location
  kind: kind
  tags: {
    environment: environment
  }
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
    WorkspaceResourceId: resourceId(subscription().subscriptionId, workspaceGroupName, 'Microsoft.OperationalInsights/workspaces', workspaceName)
  }
}
output apiInstrumentationKey string = insights.properties.InstrumentationKey
output apiId string = insights.id
