param env string
param name string
param aksVnetId string
param agentUsername string
param nsgId string
//param agentPassword string
//param keyData string

resource agentKey 'Microsoft.Compute/sshPublicKeys@2021-07-01' existing = {
  name: 'ssh-${name}-${env}'
}
resource nic 'Microsoft.Network/networkInterfaces@2020-08-01' = {
  name: 'nic-${name}-pipe-${env}'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: aksVnetId
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
     networkSecurityGroup: {
        id: nsgId
     }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
}

resource vmAgent 'Microsoft.Compute/virtualMachines@2019-07-01' = {
  name: 'vm-${name}-pipe-${env}'
  location: resourceGroup().location
  zones: [
    '1'
  ]
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
    }
    osProfile: {
       linuxConfiguration: {
          disablePasswordAuthentication: true
           ssh: {
              publicKeys:  [
                 {
                    path: '/home/${agentUsername}/.ssh/authorized_keys'
                    keyData: agentKey.properties.publicKey
                 }
              ]
           }
       }
      computerName: 'AKS-${env}'
      adminUsername: agentUsername
      //adminPassword: agentPassword
    }
     
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

output agentId string = vmAgent.id
