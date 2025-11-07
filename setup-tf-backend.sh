#!/usr/bin/env bash
# ====================================
# Simple Terraform Azure Backend Setup (WSL/Linux version)
# ====================================

# ---- Variables ----
SUBSCRIPTION_ID="4bbdd8c0-4e93-4dbb-b6e3-6c41bb381ec7"
LOCATION="eastus"
RESOURCE_GROUP_NAME="tfstate-rg"
CONTAINER_NAME="tfstate"   # shared container for all workspaces
STORAGE_ACCOUNT_NAME=""    # leave empty to create a new one

# ---- Login and set subscription ----
echo "Logging in to Azure..."
az login --only-show-errors >/dev/null

echo "Setting subscription to $SUBSCRIPTION_ID..."
az account set --subscription "$SUBSCRIPTION_ID"

# ---- Create resource group ----
echo "Creating resource group $RESOURCE_GROUP_NAME in $LOCATION..."
az group create \
  --name "$RESOURCE_GROUP_NAME" \
  --location "$LOCATION" \
  --output none

# ---- Create or reuse storage account ----
if [ -z "$STORAGE_ACCOUNT_NAME" ]; then
  RANDOM_SUFFIX=$((RANDOM % 9999))
  STORAGE_ACCOUNT_NAME="tfstate${RANDOM_SUFFIX}"
  echo "Creating new storage account: $STORAGE_ACCOUNT_NAME..."
  az storage account create \
    --name "$STORAGE_ACCOUNT_NAME" \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --output none
else
  echo "Using existing storage account: $STORAGE_ACCOUNT_NAME"
fi

# ---- Get access key ----
ACCOUNT_KEY=$(az storage account keys list \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --query "[0].value" -o tsv)

# ---- Create container ----
echo "Ensuring container '$CONTAINER_NAME' exists..."
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --account-key "$ACCOUNT_KEY" \
  --output none

# ---- Generate backend.tf ----
BACKEND_FILE="backend.tf"
cat > "$BACKEND_FILE" <<EOF
terraform {
  backend "azurerm" {
    resource_group_name  = "$RESOURCE_GROUP_NAME"
    storage_account_name = "$STORAGE_ACCOUNT_NAME"
    container_name       = "$CONTAINER_NAME"
    key                  = "terraform.tfstate"
  }
}
EOF

echo "Generated backend.tf successfully."

# ---- Initialize Terraform backend ----
echo "Initializing Terraform backend..."
terraform init -reconfigure

# ---- Summary ----
echo ""
echo "================== Terraform Backend Info =================="
echo "Resource Group      : $RESOURCE_GROUP_NAME"
echo "Storage Account     : $STORAGE_ACCOUNT_NAME"
echo "Container           : $CONTAINER_NAME"
echo "State File Key      : terraform.tfstate"
echo "==========================================================="