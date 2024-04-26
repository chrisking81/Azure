# 🔥 Azure OpenAI + APIM

This contains an example to deploy the Azure OpenAI service, fronted by APIM to ensure private connectivity, and the use of Managed Identities

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

