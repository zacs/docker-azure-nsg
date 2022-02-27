# docker-azure-nsg
Update the allowed inbound IP for a rule in an Azure Network Security Group. The primary use case is to update the inbound rule to allow your current IP address to SSH into an Azure host. 

## Setup

### 1. Service Principal Setup

In order to use the image, you'll need to create an Azure Service Principal outside of the Docker image. The process to do this is described in depth [here](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli), but the short version is run this:

```
az ad sp create-for-rbac --name ServicePrincipalName --role Contributor
```

The output will contain a password, along with an app ID and tenant ID. You'll pass these to the contianer as environment variables.

### 2. Initial Rule Creation

In order for this script to update a rule, you need to have created that rule in the first place. The important thing to do is make sure your rule is configured like so:
- Rule name is `docker_update_nsg-<YOUR_PRIORITY_LEVE>`.
  - The purpose of adding the priority to the name is so that you can run several instances of this container.
- Resource group is set to the same as what you set in your config for this image.

_TODO: Automate rule creation._

There are two ways to create the rule:
- Via the Azure portal UI: [Azure documentation](https://docs.microsoft.com/en-us/azure/virtual-network/manage-network-security-group#work-with-security-rules)
- Via CLI: [CLI documentation](https://docs.microsoft.com/en-us/cli/azure/network/nsg/rule?view=azure-cli-latest#az-network-nsg-rule-create)

## Environment Variables

| Variable | Required? |
|---|---|
| AZURE_SERVICE_PRINCIPAL_APP_ID | Yes |
| AZURE_SERVICE_PRINCIPAL_PASS | Yes |
| AZURE_TENANT_ID | Yes |
| AZURE_SUBSCRIPTION_ID | Yes |
| RULE_PRIORITY | Yes |
| RULE_INBOUND_PORT | Yes |
| NSG_RESOURCE_GROUP_NAME | Yes |
| NSG_NAME | Yes |
