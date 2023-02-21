param connectionName string
param vpnConnectionLocation string
param vnetGateway1Id string
param vnetGateway2Id string
param vpnSharedKey string

resource connection 'Microsoft.Network/connections@2022-07-01' = {
  name: connectionName
  location: vpnConnectionLocation
  properties: {
    virtualNetworkGateway1: {
      id: vnetGateway1Id
      properties: {
      }
    }
    virtualNetworkGateway2: {
      id: vnetGateway2Id
      properties: {

      }
    }
    connectionType: 'Vnet2Vnet'
    sharedKey: vpnSharedKey
    enableBgp: true
  }
}
