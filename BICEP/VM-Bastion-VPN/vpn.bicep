@description('Specifies the value of the secret that you want to create.')
@secure()
param vpnSharedKey string

param onpremGatewayId string

param hubGatewaySubnetId string

param hubGatewayPublicIpName string

param hubGatewayName string

param hubAsn int

param hubToOnpremConnectionName string
param onpremtoHubConnectionName string

param location string = resourceGroup().location

param onpremSimResourceGroup string
param onpremSimSubscriptionId string

resource hubGatewayPublicIp 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: hubGatewayPublicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource hubGateway 'Microsoft.Network/virtualNetworkGateways@2022-07-01' = {
  name: hubGatewayName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'hubGatewayConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: hubGatewaySubnetId
          }
          publicIPAddress: {
            id: hubGatewayPublicIp.id
          }
        }
      }
    ]
    gatewayType: 'Vpn'
    sku: {
      name: 'VpnGw2'
      tier: 'VpnGw2'
    }
    vpnType: 'RouteBased'
    vpnGatewayGeneration: 'Generation2'
    enableBgp: true
    bgpSettings: {
      asn: hubAsn
    }
  }
}

module hubToOnPremConnection 'vpnConnection.bicep' = {
  name: hubToOnpremConnectionName
  params: {
    vpnConnectionLocation: location
    connectionName: hubToOnpremConnectionName
    vnetGateway1Id: hubGateway.id
    vnetGateway2Id: onpremGatewayId
    vpnSharedKey: vpnSharedKey
  }
}

module onpremToHubConnection 'vpnConnection.bicep' = {
  name: onpremtoHubConnectionName
  scope: resourceGroup(onpremSimSubscriptionId, onpremSimResourceGroup)
  params: {
    vpnConnectionLocation: location
    connectionName: onpremtoHubConnectionName
    vnetGateway1Id: onpremGatewayId
    vnetGateway2Id: hubGateway.id
    vpnSharedKey: vpnSharedKey
  }
}
