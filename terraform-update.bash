#!/bin/bash

CURRENT_VERSION=""
LATEST_VERSION=""
TF_PATH=""

getLastestVersion(){
    LATEST_VERSION=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | jq --raw-output '.tag_name' | cut -c 2-)
}

getCurrentVersion(){
    CURRENT_VERSION=$(which terraform &> /dev/null && terraform --version 2> /dev/null | awk 'FNR == 1 {print $2}') || $(terraform --version 2> /dev/null | awk 'FNR == 1 {print $2}')
}

getTerraformPath(){
    TF_PATH=$(dirname which terraform) &> /dev/null
}

verifyTerraformEnv(){
    [ -z $CURRENT_VERSION ] &&
    printf "\nTerraform it not installed or not in your PATH\n\n"
    read -p  "Please provide the full path to install terraform : " TF_PATH
    [ -d $TF_PATH ] || (mkdir $TF_PATH; printf "\nDirectory$TF_PATH created.\n\n")
    [ $? -eq 0 ] || (echo "\nUnable to create $TF_PATH directory.\n"; exit 1)
}

downloadTerraform(){
    echo "Downloading Terraform ${LATEST_VERSION}..."
    curl -s -o "terraform_${LATEST_VERSION}_linux_amd64.zip" "https://releases.hashicorp.com/terraform/${LATEST_VERSION}/terraform_${LATEST_VERSION}_linux_amd64.zip"
}

installTerraform(){
    echo "Installing Terraform ${LATEST_VERSION}..."
    unzip -qq "terraform_${LATEST_VERSION}_linux_amd64.zip" -d "$TF_PATH"
    rm -f "terraform_${LATEST_VERSION}_linux_amd64.zip" && rm -f terraform
    echo "Terraform updated!"
}

# Preparation
getLastestVersion && getCurrentVersion

# Installation
[[ "${CURRENT_VERSION:1}" != ${LATEST_VERSION} ]]  && getTerraformPath && verifyTerraformEnv && downloadTerraform && installTerraform ||  echo "Latest Terraform (${LATEST_VERSION}) already installed."


