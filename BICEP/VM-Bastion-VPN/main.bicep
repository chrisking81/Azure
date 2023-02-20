param location string = resourceGroup().location
param prefix string = 'chkin'

param vnetAddressPrefix string = '10.250.0.0/23'
param gatewaySubnetAddressPrefix string = '10.250.0.0/27'
param bastionSubnetAddressPrefix string = '10.250.0.64/26'
param onpremSubnetAddressPrefix string = '10.250.1.0/26'

@description('Specifies the value of the secret that you want to create.')
@secure()
param vmPassword string

var gatewaySubnetName = 'GatewaySubnet'
var bastionSubnetName = 'AzureBastionSubnet'
var onpremSubnetName01 = '${prefix}-onprem-subnet01'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: '${prefix}-onprem-sim-vnet01'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: gatewaySubnetName
        properties: {
          addressPrefix: gatewaySubnetAddressPrefix
        }
      }
      {
        name: bastionSubnetName
        properties: {
          addressPrefix: bastionSubnetAddressPrefix
        }
      }
      {
        name: onpremSubnetName01
        properties: {
          addressPrefix: onpremSubnetAddressPrefix
        }
      }
    ]
  }
  resource bastionSubnet 'subnets' existing = {
    name: bastionSubnetName
  }
  resource gatewaySubnetname 'subnets' existing = {
    name: gatewaySubnetName
  }
  resource onpremSubnetName 'subnets' existing = {
    name: onpremSubnetName01
  }
}

resource bastionHostPublicIPAddress 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: '${prefix}-onprem-sim-bastionHost-pip01'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2022-07-01' = {
  name: '${prefix}-onprem-sim-bastionHost'
  location: location
  dependsOn: [

  ]
  sku: {
    name: 'Standard'
  }

  properties: {

    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: virtualNetwork::bastionSubnet.id
          }
          publicIPAddress: {
            id: bastionHostPublicIPAddress.id
          }
        }
      }
    ]

  }
}
