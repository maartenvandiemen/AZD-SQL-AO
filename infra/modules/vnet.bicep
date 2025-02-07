@description('The tags to associate with the resource')
param tags object

var uniqueName = uniqueString(resourceGroup().id, subscription().id)

var bastionSubnetName = 'AzureBastionSubnet'

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-${uniqueName}'
  location: resourceGroup().location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'vnet-subnet1-${uniqueName}'
        properties: {
        addressPrefix: '10.1.1.0/24'
        }
      }
      {
        name: 'vnet-subnet2-${uniqueName}'
        properties: {
        addressPrefix: '10.1.2.0/24'
        }
      }
      {
        name: bastionSubnetName
        properties: {
        addressPrefix: '10.1.253.0/24'
        }
      }
    ]
  }
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: 'vnet-bastionpip-${uniqueName}'
  location: resourceGroup().location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2024-05-01' = {
  name: 'bastionhost-${uniqueName}'
  location: resourceGroup().location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig'
        properties: {
          subnet: {
            id: last(filter(vnet.properties.subnets, subnet => subnet.name == bastionSubnetName)).id
          }
          publicIPAddress: {
            id: publicIP.id
          }      
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output vnetName string = vnet.name
output vnetSubnet1Id string = vnet.properties.subnets[0].id
output vnetSubnet1Name string = vnet.properties.subnets[0].name
output vnetSubnet2Id string = vnet.properties.subnets[1].id
output vnetSubnet2Name string = vnet.properties.subnets[1].name
output vnetSubnetBastionhostId string = vnet.properties.subnets[2].id
output vnetSubnetBastionhostName string = vnet.properties.subnets[2].name
