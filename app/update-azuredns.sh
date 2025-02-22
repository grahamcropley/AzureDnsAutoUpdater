#! /bin/bash

clientId="$AZURE_CLIENTID"
clientSecret="$AZURE_CLIENTSECRET"
tenantId="$AZURE_TENANTID"
resourceGroup="$AZURE_RESOURCEGROUP"
zoneFile="azuredns.zone"

az login --service-principal --tenant $tenantId --username $clientId --password $clientSecret >/dev/null 2>&1
echo "Azure CLI Login Complete"

if [ ! -f "$zoneFile" ]; then
  echo "Zone File Does Not Exist"
  exit 1
fi

while IFS= read -r domain; do
  if [ ! -z $domain ]; then
    echo "Processing: $domain"
    recordSetName=`cut -d "." -f 1 <<< "$domain"`
    dnsZoneName=`cut -d "." -f 2- <<< "$domain"`
    az network dns record-set cname show --resource-group grahamcropley_lab --zone-name $dnsZoneName --name $recordSetName > /dev/null 2>&1
    if [ $? -ne 0]; then
      az network dns record-set cname set-record --resource-group $resourceGroup --zone-name $dnsZoneName --record-set-name $recordSetName > /dev/null 2>&1
      if [ $? -eq 0]; then
        echo "CNAME record created successfully for $domain"
    else
      echo "CNAM record already exists for $domain"
    fi
  fi
done < "$zoneFile"
