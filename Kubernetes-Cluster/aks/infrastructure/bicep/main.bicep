//ALL
param name string
param env string
//VNET
param addressSpace string
param agicSubnet string
param aksSubnet string
param bastionSubnet string
//AKS
param clusterAdminGroupId string
param k8sVersion string
param poolCount int
param poolVmSize string
param akslimits object = {
  min: 1
  max: 2
}
//AGIC
param appgwSku string
//AGENT
param agentUsername string
param vpnAddress string
//param agentPassword string
//param keyData string
//MODULES
module vnet 'vnet.bicep' = {
  name: 'vnet-deploy'
  params: {
    name: name
    env: env
    addressSpace: addressSpace
    agicSubnet: agicSubnet
    aksSubnet: aksSubnet
    bastionSubnet: bastionSubnet
  }
}
module agic 'agw.bicep' = {
  name: 'agic-deploy'
  params: {
    name: name
    env: env
    appgw_sku: appgwSku
    vnetSubnetID: vnet.outputs.agicSubnetResourceId
  }
}

module logspace 'workspace.bicep' = {
  name: 'log-deploy'
  params: {
    name: name
    env: env
  }
}

module aks 'aks.bicep' = {
  name: 'aks-deploy'
  params: {
    name: name
    env: env
    clusterAdminGroupId: clusterAdminGroupId
    k8sVersion: k8sVersion
    poolCount: poolCount
    poolVmSize: poolVmSize
    akslimits: akslimits
    vnetSubnetID: vnet.outputs.aksSubnetResourceId
    applicationGatewayId: agic.outputs.appgwId
    appiWorkspaceId: logspace.outputs.laworkspaceId
  }
}

module roles 'roles.bicep' = {
  name: 'role-deploy'
  params: {
    name: name
    env: env
    aksId: aks.outputs.aksId
    aksAgicId: aks.outputs.aksAgicId
    aksKubeletId: aks.outputs.aksKubeletId
  }
}
module networkSecurity 'nsg.bicep' = {
  name: 'net-security-deploy'
  params: {
    bastionSubnetAddress: bastionSubnet
    env: env
    name: name
    vpnAddress: vpnAddress
  }
}
module pipelineAgent 'agent.bicep' = {
  name: 'pipeline-agent-deploy'
  params: {
    name: name
    env: env
    agentUsername: agentUsername
    //agentPassword: agentPassword
    aksVnetId: vnet.outputs.bastionSubnetResourceId
    //keyData: keyData
    nsgId: networkSecurity.outputs.nsgId
  }
}
