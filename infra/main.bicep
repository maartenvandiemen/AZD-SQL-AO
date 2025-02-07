targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@minLength(1)
@maxLength(20)
@description('Username for the VMs')
param vmUsername string = 'adminUser'

@minLength(12)
@maxLength(123)
@secure()
@description('Password for the VMs')
#disable-next-line secure-parameter-default
param vmPassword string = 'Password1234!'

// Tags that should be applied to all resources.
// 
// Note that 'azd-service-name' tags should be applied separately to service host resources.
// Example usage:
//   tags: union(tags, { 'azd-service-name': <service name in azure.yaml> })
var tags = {
  'azd-env-name': environmentName
}

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

module vnet 'modules/vnet.bicep' = {
  name: 'vnet-${environmentName}'
  scope: rg
  params:{
    tags: tags
  }
}

module vm1'modules/VM.bicep' = {
  name: 'vm1-${environmentName}'
  scope: rg
  params:{
    tags: tags
    vnetName: vnet.outputs.vnetName
    subnetName: vnet.outputs.vnetSubnet1Name
    username: vmUsername
    password: vmPassword
    vmName: 'mtt-dc-01'
  }
}
