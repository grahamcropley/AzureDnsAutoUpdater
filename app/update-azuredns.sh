#! /bin/bash

stty -echoctl # hide ^C 2>/dev/null

# function called by trap
endnicely() {
    tput setaf 1
    printf "\nSIGINT caught\n"
    tput sgr0
    exit 1
}

trap 'endnicely' SIGINT

clientId="$AZURE_CLIENTID"
clientSecret="$AZURE_CLIENTSECRET"
tenantId="$AZURE_TENANTID"
resourceGroup="$AZURE_RESOURCEGROUP"
zoneFile="azuredns.zone"

INFO=$(tput bold setaf 7 2>/dev/null)
WARN=$(tput bold setaf 3 2>/dev/null)
OK=$(tput bold setaf 2 2>/dev/null)
ERR=$(tput bold setaf 1 2>/dev/null)
NORMAL=$(tput sgr0 2>/dev/null)

az login --service-principal --tenant $tenantId --username $clientId --password $clientSecret > /dev/null 2>&1
printf "${NORMAL}Azure CLI Login ${OK}Successul\n"

if [ ! -f "$zoneFile" ]; then
  printf "${ERR}Zone File Does Not Exist${NORMAL}\n"
  exit 1
fi

while IFS= read -r domain; do
  if [ ! -z $domain ]; then
    domain=$(echo "$domain" | tr -d '\r')
    printf "${NORMAL}Processing: CNAME for ${INFO}$domain "
    recordSetName=`cut -d "." -f 1 <<< "$domain" | tr -d '\r' | tr -d '\n'`
    dnsZoneName=`cut -d "." -f 2- <<< "$domain" | tr -d '\r' | tr -d '\n'`
    result=`az network dns record-set cname show --resource-group $resourceGroup --zone-name $dnsZoneName --name $recordSetName > /dev/null 2>&1`
    if [ $? -ne 0 ]; then
      result=`az network dns record-set cname set-record --resource-group $resourceGroup --zone-name $dnsZoneName --record-set-name $recordSetName --cname $dnsZoneName > /dev/null 2>&1`
      if [ $? -eq 0 ]; then
        printf "${NORMAL} ${OK}created${NORMAL}\n"
      else
        printf "${NORMAL} ${ERR}failed${NORMAL}\n"
      fi
    else
      printf "${NORMAL} ${WARN}already exists${NORMAL}\n"
    fi
  fi
done < "$zoneFile"
