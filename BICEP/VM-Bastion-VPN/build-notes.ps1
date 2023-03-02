
$rg = New-AzResourceGroup -name 'chkin-onprem-sim-rg' -location uksouth

New-AzKeyVault -VaultName 'chkin-onprem-sim-kv01' -ResourceGroupName $rg.ResourceGroupName -Location $rg.Location -EnabledForTemplateDeployment -Sku Premium

$secretValue = read-host -prompt "Enter Password" -asSecureString

set-azkeyvaultsecret -vaultname 'chkin-onprem-sim-kv01' -name 'defaultVmPassword' -secretValue $secretvalue

$vpnSharedSecret = Read-Host "Enter shared key" -AsSecureString

Set-AzKeyVaultSecret -VaultName 'chkin-onprem-sim-kv01' -Name 'vpnSharedKey' -SecretValue $vpnSharedSecret

New-AzResourceGroupDeployment -ResourceGroupName $rg.ResourceGroupName -TemplateFile ./main.bicep -TemplateParameterFile ./main.parameters.json 

$hubRG = get-AzResourceGroup -Name 'chkin-vnethub-uksouth'

New-AzResourceGroupDeployment -ResourceGroupName $hubRG.ResourceGroupName -TemplateFile ./vpn.bicep -TemplateParameterFile ./vpn.parameters.json