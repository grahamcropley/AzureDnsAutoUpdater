#! /bin/bash

clientId="$AZURE_CLIENTID"
clientSecret="$AZURE_CLIENTSECRET"
tenantId="$AZURE_TENANTID"
resourceGroup="$AZURE_RESOURCEGROUP"
cname=`cut -d "." -f 1 <<< "$AZURE_CNAME"`
dnsZoneName=`cut -d "." -f 2- <<< "$AZURE_CNAME"`

az login --service-principal --tenant $tenantId --username $clientId --password $clientSecret >/dev/null 2>&1
az network dns record-set cname set-record --resource-group $resourceGroup --zone-name dnsZoneName --record-set-name $cname
