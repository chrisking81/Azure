@description('Specifies the name of the key vault.')
param keyVaultName string = '${uniqueString(resourceGroup().id)}-kv1'

param storageAccountName string = '${uniqueString(resourceGroup().id)}sa1'

@description('Specifies the Azure location where the resources should be created.')
param location string = resourceGroup().location

param keyExpiration int = dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))

param managedIdentityName string = 'cmk-MI'

resource keyvault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'premium'
    }
    tenantId: tenant().tenantId
    softDeleteRetentionInDays: 7
    enableRbacAuthorization: true
    publicNetworkAccess: 'enabled'
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: [
        {
          value: '90.204.77.120/32'
        }
        {
          value: '2.4.6.8/32'
        }
      ]
      virtualNetworkRules: []
    }
  }
}

// resource cmkKey 'Microsoft.KeyVault/vaults/keys@2022-07-01' = {
//   parent: keyvault
//   name: 'cmkKey01'
//   properties: {
//     kty: 'RSA'
//     attributes: {
//       enabled: true
//       exp: keyExpiration
//     }
//     keySize: 4096
//   }
// }

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: managedIdentityName
  location: location
}

resource KeyVaultCryptoServiceEncryptionUserDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: 'e147488a-f6f5-4113-8e2d-b22465e65bf6'
}

module roleAssignment 'modules/role-assignment.bicep' = {
  name: 'role-assignment'
  params: {
    keyVaultName: keyvault.name
    roleAssignmentName: guid(keyvault.id, managedIdentity.properties.principalId, KeyVaultCryptoServiceEncryptionUserDef.id)
    roleDefinitionId: KeyVaultCryptoServiceEncryptionUserDef.id
    principalId: managedIdentity.properties.principalId
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    isLocalUserEnabled: false
    publicNetworkAccess: 'enabled'
    isSftpEnabled: false
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowSharedKeyAccess: false
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: [
        {
          value: '90.204.77.120'
          action: 'Allow'
        }
        {
          value: '2.4.6.10'
          action: 'Allow'
        }
      ]

    }
    encryption: {
      requireInfrastructureEncryption: true
      services: {
        queue: {
          keyType: 'Account'
        }
        table: {
          keyType: 'Account'
        }

      }
    }
  }
}
