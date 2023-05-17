param appgw_sku string
param name string
param env string
param vnetSubnetID string

resource ipPub 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: 'pip-${name}-${env}'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}
@description('DO NOT EXECUTE OVER EXISTING AGIC BY ANY MEANS AS IT WILL OVERRIDE ALL RULE TO DEFAULT')
resource appgw 'Microsoft.Network/applicationGateways@2020-11-01' = {
  name: 'agic-${name}-${env}'
  location: resourceGroup().location
  properties: {
    sku: {
      name: appgw_sku
      tier: appgw_sku
      capacity: 1
    }

    enableHttp2: true
    gatewayIPConfigurations: [
      {
        name: 'appgw-ip-config'

        properties: {
          subnet: {
            id: vnetSubnetID
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appgw-public-frontend-ip'
        properties: {
          publicIPAddress: {
            id: ipPub.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'default'
        properties: {
          backendAddresses: []
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'defaulthttp'
        properties: {
          port: 80
          protocol: 'Http'
        }
      }
    ]
    httpListeners: [
      {
        name: 'default_listenner'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', 'agic-${name}-${env}', 'appgw-public-frontend-ip')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', 'agic-${name}-${env}', 'port_80')
          }

          protocol: 'Http'
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'rule1'
        properties: {
          ruleType: 'Basic'
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', 'agic-${name}-${env}', 'default_listenner')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', 'agic-${name}-${env}', 'default')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', 'agic-${name}-${env}', 'defaulthttp')
          }
        }
      }
    ]
  }
}
output appgwId string = appgw.id

