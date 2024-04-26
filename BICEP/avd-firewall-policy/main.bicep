param hubFwPolicyName string = 'dev4-hubFW-AzFwP-uks-01'
param location string = 'uksouth'
param avdHostNetwork array = [ '10.11.1.0/24']
param zenNodesIPList array
param zenBrokerIpList array

resource hubFwPolicy 'Microsoft.Network/firewallPolicies@2023-05-01' existing = {
  name: hubFwPolicyName
}

//output hubFwPolicyId string = hubFwPolicy.id

resource zenNodesIpGroup 'Microsoft.Network/ipGroups@2023-05-01' = {
 name: 'zenNodesIpGroup'
 location: location
 properties: {
  ipAddresses: zenNodesIPList
 }
}

resource zenBrokerIpGroup 'Microsoft.Network/ipGroups@2023-05-01' = {
  name: 'zenBrokersIpGroup'
  location: location
  properties: {
    ipAddresses: zenBrokerIpList
  }
  dependsOn: [
    zenNodesIpGroup
  ]
}

resource avdCoreRcg 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-05-01' = {
  name: 'AVD-Core'
  parent: hubFwPolicy 
  properties: {
    priority: 1000
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        name: 'NetworkRules-AVD'
        priority: 1500
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'Azure Portal Support'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: avdHostNetwork
            sourceIpGroups: [
              
            ]
            destinationAddresses: [
            ]
            destinationFqdns: [
              'wvdportalstorageblob.blob.core.windows.net'
            ]
            destinationPorts: [
              '443'
            ]
          }
        ]
      }
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        name: 'ApplicationRules-AVD'
        priority: 3000
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'Agent and SxS Stack Updates'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            targetFqdns: [
              'mrsglobalsteus2prod.blob.core.windows.net'
            ]
            sourceAddresses: avdHostNetwork
            terminateTLS: false
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Agent traffic'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            targetFqdns: [
              'gcs.prod.monitoring.core.windows.net'
            ]
            sourceAddresses: avdHostNetwork
            terminateTLS: false
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Agent traffic - diagnostic'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            targetFqdns: [
              '*.prod.warm.ingest.monitor.core.windows.net'
            ]
            sourceAddresses: avdHostNetwork
            terminateTLS: false
          }
          {
            ruleType: 'ApplicationRule'
            name: 'Authentication to Entra'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            targetFqdns: [
              'login.microsoftonline.com'
            ]
            sourceAddresses: avdHostNetwork
            terminateTLS: false
          }
          // {
          //   ruleType: 'ApplicationRule'
          //   name: 'Azure Portal Support'
          //   protocols: [
          //     {
          //       protocolType: 'Https'
          //       port: 443
          //     }
          //   ]
          //   targetFqdns: [
          //     'wvdportalstorageblob.blob.core.windows.net'
          //   ]
          //   sourceAddresses: avdHostNetwork
          //   terminateTLS: false
          // }

        ]
      }
    ]
  }
}

resource ZscalerRcg 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-05-01' = {
  name: 'Zscaler-Core'
  parent: hubFwPolicy 
  properties: {
    priority: 2000
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        name: 'NetworkRules-Zscaler'
        priority: 1500
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'Zscaler Service Discovery and PAC'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: avdHostNetwork
            sourceIpGroups: [
              
            ]
            destinationAddresses: [
            ]
            destinationFqdns: [
              'mobile.zscloud.net'
              'login.zscloud.net'
              'pac.zscloud.net'
              'd32a6ru7mhaq0c.cloudfront.net'              
            ]
            destinationPorts: [
              '80'
              '443'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Cert Validation'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: avdHostNetwork
            destinationFqdns: [
              'ocsp.digicert.com'
              'crl3.digicert.com'
              'crl4.digicert.com'              
            ]
            destinationPorts: [
              '80'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Zscaler ZCC Auth - Azure AD'
            ipProtocols: [
              'TCP'
            ]
            sourceAddresses: avdHostNetwork
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: []
            destinationFqdns: [
              'login.microsoftonline.com'
              'aadcdn.msauth.net'
              'aadcdn.msftauth.net'
            ]
            destinationPorts: [
              '80'
              '443'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Zscaler Tunnel to Zscaler'
            ipProtocols: [
              'TCP'
              'UDP'
            ]
            sourceAddresses: avdHostNetwork
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: [
              zenNodesIpGroup.id
            ]
            destinationFqdns: []
            destinationPorts: [
              '80'
              '443'
              '8080'
            ]
          }
          {
            ruleType: 'NetworkRule'
            name: 'Zscaler ZCC Tunnel for ZPA'
            ipProtocols: [
              'TCP'
              'UDP'
            ]
            sourceAddresses: avdHostNetwork
            sourceIpGroups: []
            destinationAddresses: []
            destinationIpGroups: [
              zenBrokerIpGroup.id
            ]
            destinationFqdns: []
            destinationPorts: [
              '443'
            ]
          }

        ]
      }
      // {
      //   ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
      //   action: {
      //     type: 'Allow'
      //   }
      //   name: 'ApplicationRules-AVD'
      //   priority: 3000
      //   rules: [
      //     {
      //       ruleType: 'ApplicationRule'
      //       name: 'Agent and SxS Stack Updates'
      //       protocols: [
      //         {
      //           protocolType: 'Https'
      //           port: 443
      //         }
      //       ]
      //       targetFqdns: [
      //         'mrsglobalsteus2prod.blob.core.windows.net'
      //       ]
      //       sourceAddresses: avdHostNetwork
      //       terminateTLS: false
      //     }
      //     {
      //       ruleType: 'ApplicationRule'
      //       name: 'Agent traffic'
      //       protocols: [
      //         {
      //           protocolType: 'Https'
      //           port: 443
      //         }
      //       ]
      //       targetFqdns: [
      //         'gcs.prod.monitoring.core.windows.net'
      //       ]
      //       sourceAddresses: avdHostNetwork
      //       terminateTLS: false
      //     }
      //     {
      //       ruleType: 'ApplicationRule'
      //       name: 'Agent traffic - diagnostic'
      //       protocols: [
      //         {
      //           protocolType: 'Https'
      //           port: 443
      //         }
      //       ]
      //       targetFqdns: [
      //         '*.prod.warm.ingest.monitor.core.windows.net'
      //       ]
      //       sourceAddresses: avdHostNetwork
      //       terminateTLS: false
      //     }
      //     {
      //       ruleType: 'ApplicationRule'
      //       name: 'Authentication to Entra'
      //       protocols: [
      //         {
      //           protocolType: 'Https'
      //           port: 443
      //         }
      //       ]
      //       targetFqdns: [
      //         'login.microsoftonline.com'
      //       ]
      //       sourceAddresses: avdHostNetwork
      //       terminateTLS: false
      //     }
      //     {
      //       ruleType: 'ApplicationRule'
      //       name: 'Azure Portal Support'
      //       protocols: [
      //         {
      //           protocolType: 'Https'
      //           port: 443
      //         }
      //       ]
      //       targetFqdns: [
      //         'wvdportalstorageblob.blob.core.windows.net'
      //       ]
      //       sourceAddresses: avdHostNetwork
      //       terminateTLS: false
      //     }

      //   ]
      // }
    ]
  }
  dependsOn: [
    zenBrokerIpGroup
    zenNodesIpGroup
    avdCoreRcg
  ]
}
