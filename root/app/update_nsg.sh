#!/usr/bin/with-contenv sh

update_nsg() {

  if [ ! -z "$@" ]; then
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

      # Select the subscription
      #echo "Running: az account set --subscription ${_subscription_id}"
      #az account set --subscription ${_subscription_id}

      # updating the rule
      echo "Rule details"
      echo "------------"
      echo "_rule_port: ${_rule_port}"
      echo "_rule_priority: ${_rule_priority}"

      _rule_name=docker_update_nsg-${_rule_priority}

      echo "Updating rule ${_rule_name}"
      az network nsg rule update -g ${_rule_nsg_resource_group} --nsg-name ${_rule_nsg_name} \
                  -n ${_rule_name} --priority ${_rule_priority} \
                  --source-address-prefixes ${_rule_public_ip} --source-port-ranges '*' \
                  --destination-address-prefixes '*' --destination-port-ranges ${_rule_port} \
                  --access Allow --protocol '*' \
                  --description 'Update rule from update_nsg image at $(date).' --verbose
      # output
      echo "Rule update complete."
  else
      echo "No desired IP specified."
  fi

}

getPublicIpAddress() {
  if [ "$RRTYPE" == "A" ]; then
    # Use DNS_SERVER ENV variable or default to 1.1.1.1
    DNS_SERVER=${DNS_SERVER:=1.1.1.1}

    # try dns method first.
    CLOUD_FLARE_IP=$(dig +short @$DNS_SERVER ch txt whoami.cloudflare +time=3 | tr -d '"')
    CLOUD_FLARE_IP_LEN=${#CLOUD_FLARE_IP}

    # if using cloud flare fails, try opendns (some ISPs block 1.1.1.1)
    IP_ADDRESS=$([ $CLOUD_FLARE_IP_LEN -gt 15 ] && echo $(dig +short myip.opendns.com @resolver1.opendns.com +time=3) || echo "$CLOUD_FLARE_IP")

    # if dns method fails, use http method
    if [ "$IP_ADDRESS" = "" ]; then
      IP_ADDRESS=$(curl -sf4 https://ipinfo.io | jq -r '.ip')
    fi

    echo $IP_ADDRESS
  elif [ "$RRTYPE" == "AAAA" ]; then
    # try dns method first.
    IP_ADDRESS=$(dig +short @2606:4700:4700::1111 -6 ch txt whoami.cloudflare | tr -d '"')

    # if dns method fails, use http method
    if [ "$IP_ADDRESS" = "" ]; then
      IP_ADDRESS=$(curl -sf6 https://ifconfig.co)
    fi

    echo $IP_ADDRESS
  fi
}
