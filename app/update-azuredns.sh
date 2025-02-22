#! /bin/bash

clientId="$AZURE_CLIENTID"
clientSecret="$AZURE_CLIENTSECRET"
tenantId="$AZURE_TENANTID"
resourceGroup="$AZURE_RESOURCEGROUP"
zoneFile="azuredns.zone"

INFO=$(tput bold setaf 7)
WARN=$(tput bold setaf 3)
OK=$(tput bold setaf 2)
ERR=$(tput bold setaf 1)
NORMAL=$(tput sgr0)

az login --service-principal --tenant $tenantId --username $clientId --password $clientSecret > /dev/null 2>&1
echo "${NORMAL}Azure CLI Login ${OK}Successul"

if [ ! -f "$zoneFile" ]; then
  echo "${ERR}Zone File Does Not Exist${NORMAL}"
  exit 1
fi

while IFS= read -r domain; do
  
  if [ ! -z $domain ]; then
    printf "${NORMAL}Processing: ${INFO}$domain"
    recordSetName=`cut -d "." -f 1 <<< "$domain" | tr -d '\r' | tr -d '\n'`
    dnsZoneName=`cut -d "." -f 2- <<< "$domain" | tr -d '\r' | tr -d '\n'`
    az network dns record-set cname show --resource-group $resourceGroup --zone-name $dnsZoneName --name $recordSetName > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      az network dns record-set cname set-record --resource-group $resourceGroup --zone-name $dnsZoneName --record-set-name $recordSetName --cname $dnsZoneName > /dev/null 2>&1
      if [ $? -eq 0 ]; then
        printf "${NORMAL} CNAME ${OK}created${NORMAL}\n"
      else
        printf "${NORMAL} CNAME ${ERR}failed${NORMAL}\n"
      fi
    else
      printf "${NORMAL} CNAME ${WARN}already exists${NORMAL}\n"
    fi
  fi
done < "$zoneFile"
