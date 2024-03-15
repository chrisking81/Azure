# 🔥 Firewall Policy Example - AVD + Zscaler

This contains an example to deploy rule collection groups to existing Azure Firewall Rule Policies, to support AVD + Zscaler. The example uses two firewalls, a central hub, and an egress firewall, and assumes the appropriate firewall rule policies already exist.

## Quick Deploy

To quickly deploy the examples as provided, you need to run two separate deployments as shown below:

```powershell
New-AzResourceGroupDeployment -Name "hub-firewall-rcg" `
          -Location "uksouth" `
          -ResourceGroupName "dev4-hub-rg-uks-01" `
          -TemplateFile ./main.bicep `
          -TemplateParameterFile ./main.bicepparm `
          -Verbose   

New-AzResourceGroupDeployment -Name "egress-firewall-rcg" `
          -Location "uksouth" `
          -ResourceGroupName "dev4-egress-rg-uks-01" `
          -TemplateFile ./egress.bicep `
          -TemplateParameterFile ./egress.bicepparm `
          -Verbose   
```

