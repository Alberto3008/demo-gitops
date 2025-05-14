#!/bin/bash

NombreCliente="$1"
AzureOpenAIName="$2"
AzureOpenAIEndpoint="$3"
AzureOpenAIKey="$4"
InsightString="$5"
ClientEmail="$6"
ClientPassword="$7"
DNS="intelewriter-demos-${1}.swedencentral.cloudapp.azure.com"

echo $NombreCliente
echo $AzureOpenAIName
echo $AzureOpenAIEndpoint
echo $AzureOpenAIKey
echo $InsightString
echo $DNS

# EDITAR .env

sed -i "s/intelequia-demos-sw-openai/$AzureOpenAIName/g" /home/intelequiaUser/Intelequia.Intelewriter.Deploy/.env

sed -i~ '/^AZURE_ASSISTANTS_API_KEY=/s/=.*/="'$AzureOpenAIKey'"/' /home/intelequiaUser/Intelequia.Intelewriter.Deploy/.env

sed -i~ '/^RAG_AZURE_OPENAI_API_KEY=/s/=.*/="'$AzureOpenAIKey'"/' /home/intelequiaUser/Intelequia.Intelewriter.Deploy/.env

InsightStringScape=$(echo "$InsightString" | sed "s/\//\\\\\//g")

sed -i~ '/^APPLICATIONINSIGHTS_CONNECTION_STRING=/s/=.*/="'$InsightStringScape'"/' /home/intelequiaUser/Intelequia.Intelewriter.Deploy/.env


#Nuevo DNS
rename_values_in_files() {
    local path="$1"
    local oldValue="$2"
    local newValue="$3"

    find "$path" -type f | while read -r file; do
        if [ -s "$file" ]; then
            sed -i "s/$oldValue/$newValue/g" "$file"
            echo "Reemplazado en $file"
        fi
    done
}

rootPath="/home/intelequiaUser/Intelequia.Intelewriter.Deploy/"
oldValue="demo.intelewriter.com"
newValue="$DNS"

if [ -z "$newValue" ]; then
    echo "Por favor, proporciona un nuevo valor como argumento."
    echo "Uso: ./init.sh <nuevo_valor>"
    exit 1
fi

rename_values_in_files "$rootPath" "$oldValue" "$newValue"

sudo rm /home/intelequiaUser/Intelequia.Intelewriter.Deploy/nginx/certbot -rf

cd /home/intelequiaUser/Intelequia.Intelewriter.Deploy

sleep 10

bash ./init-letsencrypt.sh

sleep 10

bash ./azureARCLogin.sh latest

sleep 15

docker exec -i LibreChat /bin/sh -c "yes | npm run create-user $ClientEmail $NombreCliente $NombreCliente $ClientPassword"
