# 🚓 Policy Assignment - Allow Resource Types

This assigns a built-in policy definition to a management group scope, to only allow the permitted resource types to be deployed.

## Built-in Policy
| Name                 | Description                                        | Policy ID                      |
| -------------------- | -------------------------------------------------- | ------------------------------ |
| Allowed resource types | This policy enables you to specify the resource types that your organization can deploy. Only resource types that support 'tags' and 'location' will be affected by this policy. To restrict all resources please duplicate this policy and change the 'mode' to 'All'. | a08ec900-254a-4555-9bf5-e42af04b5c5c |

## Parameters

| Name                  | Description                                                       | Type   | Default              |
| --------------------- | ----------------------------------------------------------------- | ------ | -------------------- |
| targetMgID            | Target Management Group ID for policy assignment                  | string | contoso-corp         |
| enforcementMode       | Choose whether to enforce or not                                  | string | Default|
| listOfResourceTypesAllowed                 | Resource Types approved for deployment       | array  | \["Microsoft.Resources/subscriptions/resourceGroups"]                    |


## Quick Deploy

To quickly assign the policy taking the defaults, to only allow the deployment of resource groups, run:

```powershell
New-AzManagementGroupDeployment -Name "Allow-resource-types-assignment" `
          -Location "northeurope" `
          -TemplateFile ./ALLOW-ResourceTypesPolicyAssignment.json `
          -TemplateParameterFile ./ALLOW-ResourceTypesPolicyAssignment.parameters.json `
          -Verbose   
```

