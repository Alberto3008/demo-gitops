#!/bin/bash

#wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq &&\
#    chmod +x /usr/local/bin/yq

NombreCliente="$1"
AzureOpenAIName="$2"
AzureOpenAIEndpoint="$3"
AzureOpenAIKey="$4"
InsightString="$5"
DNS="intelewriter-demos-${1}.swedencentral.cloudapp.azure.com"

echo $NombreCliente
echo $AzureOpenAIName
echo $AzureOpenAIEndpoint
echo $AzureOpenAIKey
echo $InsightString
echo $DNS

#EDITAR YAML
#yq -i '.a.b[0].c = "cool"' file.yaml
#yq '.endpoints.azureOpenAI.group = "${AZURE_RESOURSE_NAME}-assistants"' sample.yml




# EDITAR .env
#sed -i -E 's|(BACKEND_REPO=).*|\1$NombreCliente|' .env
sed -i "s/intelequia-demos-sw-openai/$AzureOpenAIName/g" /home/intelequiaUser/Intelequia.Intelewriter.Deploy/.env

#sed -i~ '/^AZURE_RESOURSE_NAME=/s/=.*/="'$AzureOpenAIName'"/' /home/intelequiaUser/Intelequia.Intelewriter.Deploy/.env

sed -i~ '/^AZURE_ASSISTANTS_API_KEY=/s/=.*/="'$AzureOpenAIKey'"/' /home/intelequiaUser/Intelequia.Intelewriter.Deploy/.env

#sed -i~ '/^RAG_AZURE_OPENAI_ENDPOINT=/s/=.*/="'$AzureOpenAIEndpoint'"/' /home/intelequiaUser/Intelequia.Intelewriter.Deploy/.env

sed -i~ '/^RAG_AZURE_OPENAI_API_KEY=/s/=.*/="'$AzureOpenAIKey'"/' /home/intelequiaUser/Intelequia.Intelewriter.Deploy/.env

sed -i~ '#^APPLICATIONINSIGHTS_CONNECTION_STRING=#s#=.*#="'$InsightString'"#' /home/intelequiaUser/Intelequia.Intelewriter.Deploy/.env

#sed -i~ '/^TEST_VAR=/s/=.*/="'$NombreCliente'"/' file.env

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

bash ./init-letsencrypt.sh

bash ./azureARCLogin.sh latest

docker-compose up -d

#docker-compose up -d

#./home/intelequiaUser/Intelequia.Intelewriter.Deploy/azureARCLogin.sh preview
