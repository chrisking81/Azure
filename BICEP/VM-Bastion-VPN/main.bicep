param location string = resourceGroup().location
param prefix string = 'chkin'

param vnetAddressPrefix string = '10.250.0.0/23'
param gatewaySubnetAddressPrefix string = '10.250.0.0/27'
param bastionSubnetAddressPrefix string = '10.250.0.64/26'
param onpremSubnetAddressPrefix string = '10.250.1.0/26'

@description('Specifies the value of the secret that you want to create.')
@secure()
param vmPassword string
param vmUsername string
param OSVersion string = '2022-datacenter-azure-edition'
param vmSize string = 'Standard_D2s_v5'

var gatewaySubnetName = 'GatewaySubnet'
var bastionSubnetName = 'AzureBastionSubnet'
var onpremSubnetName01 = '${prefix}-onprem-subnet01'
var dnsVM01Name = '${prefix}-onprem-vm-dns01'
var dnsVM01NicName = '${dnsVM01Name}-nic'
var storageAccountName = take('${prefix}onpremsim${uniqueString(resourceGroup().id)}', 24)

resource storageaccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

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

resource dnsVMnic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: dnsVM01NicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconf1'
        properties: {
          privateIPAllocationMethod: 'dynamic'
          subnet: {
            id: virtualNetwork::onpremSubnetName.id
          }
          primary: true
        }
      }
      {
        name: 'ipconf2'
        properties: {
          privateIPAllocationMethod: 'dynamic'
          subnet: {
            id: virtualNetwork::onpremSubnetName.id
          }
        }
      }
    ]
  }
}

resource dnsVM 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: dnsVM01Name
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: 'dnsVM01'
      adminUsername: vmUsername
      adminPassword: vmPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: dnsVMnic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: storageaccount.properties.primaryEndpoints.blob
      }
    }
  }
}

resource dnsVMShutdownSchedule 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-${dnsVM01Name}'
  location: location
  properties: {
    status: 'Enabled'
    dailyRecurrence: {
      time: '2000'
    }
    timeZoneId: 'UTC'
    targetResourceId: dnsVM.id
    taskType: 'ComputeVmShutdownTask'
  }
}
