#!/bin/sh -l

# Ensure the workflow fails on error
set -e

echo "===================================="
echo "Starting rule update."

_app_id=${AZURE_APP_ID}
_password=${AZURE_PASSWORD}
_tenant_id=${AZURE_TENANT_ID}
_subscription_id=${AZURE_SUBSCRIPTION_ID}
_rule_priority=${RULE_PRIORITY}
_rule_port=${RULE_INBOUND_PORT}
_rule_id_for_removal=${RULE_ID_FOR_REMOVAL}
_rule_nsg_resource_group=${NSG_RESOURCE_GROUP_NAME}
_rule_nsg_name=${NSG_NAME}
_rule_public_ip=$(dig +short myip.opendns.com @resolver1.opendns.com) # Get runner's public IP

echo "Using IP: ${_rule_public_ip}"

# Login to azure using service principal
echo "Running: az login --service-principal -u ${_app_id} -p ${_password} --tenant ${_tenant_id}"
az login --service-principal -u ${_app_id} -p ${_password} --tenant ${_tenant_id}

# updating the rule
echo "Rule details"
echo "------------"
echo "_rule_port: ${_rule_port}"
echo "_rule_priority: ${_rule_priority}"

_rule_name=docker_update_nsg-${_rule_priority}
_rule_description="Updated rule from docker azure-nsg image at" + $(date)

echo "_rule_name: ${_rule_name}"
az network nsg rule update -g ${_rule_nsg_resource_group} --nsg-name ${_rule_nsg_name} \
            -n ${_rule_name} --priority ${_rule_priority} \
            --source-address-prefixes ${_rule_public_ip} --source-port-ranges '*' \
            --destination-address-prefixes '*' --destination-port-ranges ${_rule_port} \
            --access Allow --protocol '*' \
            --description ${_rule_description} --verbose
# output
echo "Rule update complete."
