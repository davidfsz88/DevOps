param env string
param aksVnetId string
resource sharedvpn 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  scope: resourceGroup('b72467e5-6291-4244-b3cc-a36741f6ca13','rg-vpn-shared')
  name: 'vnet-vpn-shared'
}
resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-07-01' = {
  name: '${sharedvpn.name}/peer-${env}-link'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: aksVnetId
    }
  }
}
