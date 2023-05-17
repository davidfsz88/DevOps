param publisherEmail string
param publisherName string

@allowed([
  'Developer'
  'Standard'
  'Premium'
])
param sku string = 'Developer'
param skuCount int = 1
param subnetId string
param instrumentationKey string
param appiId string
param virtualNetworkType string
var apiManagementServiceName = 'apim-${uniqueString(resourceGroup().id)}-dev'

resource apim 'Microsoft.ApiManagement/service@2020-06-01-preview' = {
  name: apiManagementServiceName
  location: resourceGroup().location
  sku: {
    name: sku
    capacity: skuCount
  }

  properties: {
    publisherName: publisherName
    publisherEmail: publisherEmail
    virtualNetworkType: virtualNetworkType
    virtualNetworkConfiguration: {
      subnetResourceId: subnetId
    }
  }
}

resource namedValueAppInsightsKey 'Microsoft.ApiManagement/service/namedValues@2020-06-01-preview' = {
  name: '${apim.name}/appinsights-key'
  properties: {
    tags: []
    secret: false
    displayName: 'appinsights-key'
    value: instrumentationKey
  }
}

// Add Application Insights to API management
resource appInsightsAPIManagement 'Microsoft.ApiManagement/service/loggers@2020-06-01-preview' = {
  name: '${apim.name}/applicationinsights'
  properties: {
    loggerType: 'applicationInsights'
    description: 'app specific Application Insights instance.'
    resourceId: appiId
    credentials: {
      instrumentationKey: '{{appinsights-key}}'
    }
  }
  dependsOn: [
    namedValueAppInsightsKey
  ]
}
resource symbolicname 'Microsoft.ApiManagement/service/diagnostics@2021-08-01' = {
  name: 'applicationinsights'
  parent: apim
  properties: {
    alwaysLog: 'allErrors'
    logClientIp: true
    loggerId: appInsightsAPIManagement.id
    verbosity: 'verbose'
  }
}
