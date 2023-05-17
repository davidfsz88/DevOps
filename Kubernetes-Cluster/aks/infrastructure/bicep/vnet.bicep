param addressSpace string = '10.160.0.0/16'
param aksSubnet string
param agicSubnet string
param bastionSubnet string
param name string
param env string
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'vnet-${name}-${env}'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressSpace
      ]
    }
    subnets: [
      {
        name: 'subnet-aks'
        properties: {
          addressPrefix: aksSubnet
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'subnet-agic'
        properties: {
          addressPrefix: agicSubnet
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'subnet-bastion'
        properties: {
          addressPrefix: bastionSubnet
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}
resource sharedvpn 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  scope: resourceGroup('b72467e5-6291-4244-b3cc-a36741f6ca13','rg-vpn-shared')
  name: 'vnet-vpn-shared'
}
resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: '${virtualNetwork.name}/peer-${env}-link'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: true
    remoteVirtualNetwork: {
      id: sharedvpn.id
    }
  }
}

module peeringmodule 'peering.bicep' = {
  name: 'peering-deploy'
  scope: resourceGroup('b72467e5-6291-4244-b3cc-a36741f6ca13','rg-vpn-shared')
  params: {
    aksVnetId: virtualNetwork.id
    env: env
  }
}

output aksSubnetResourceId string = virtualNetwork.properties.subnets[0].id
output agicSubnetResourceId string = virtualNetwork.properties.subnets[1].id
output bastionSubnetResourceId string = virtualNetwork.properties.subnets[2].id
output vnetId string = virtualNetwork.id
