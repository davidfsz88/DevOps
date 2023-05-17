param name string
param env string
param vpnAddress string
param bastionSubnetAddress string
resource akspipensg 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'nsg-${name}-pipe-${env}'
  location: resourceGroup().location
  properties: {
    
    securityRules: [
      {
        name: 'nsgRule'
        properties: {
          description: 'vpn acces to pipeline'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: vpnAddress
          destinationAddressPrefix: bastionSubnetAddress
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

output nsgId string = akspipensg.id
