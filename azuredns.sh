appId=""
appSecret=""
tenantId=""
rgName=""
zoneName=""

az login --service-principal --tenant $tenantId --username $appId --password $appSecret >/dev/null 2>&1