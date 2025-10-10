# ====================================
# Simple Terraform Azure Backend Setup
# ====================================

param (
    [string]$SubscriptionId = "3b2b9d10-f659-45c4-9068-5ca3a8a64cd2",
    [string]$Location = "eastus",
    [string]$ResourceGroupName = "tfstate-rg",
    [string]$ContainerName = "tfstate",  # shared container for all workspaces
    [string]$StorageAccountName = ""      # optional: reuse existing storage account
)

# --- Login and set subscription ---
Write-Host "Logging in to Azure..."
az login | Out-Null

Write-Host "Setting subscription to $SubscriptionId..."
az account set --subscription $SubscriptionId

# --- Create resource group ---
Write-Host "Creating resource group $ResourceGroupName in $Location..."
az group create --name $ResourceGroupName --location $Location | Out-Null

# --- Create or reuse storage account ---
if ([string]::IsNullOrEmpty($StorageAccountName)) {
    $RandomSuffix = Get-Random -Maximum 9999
    $StorageAccountName = "tfstate$RandomSuffix"
    Write-Host "Creating new storage account: $StorageAccountName..."
    az storage account create `
        --name $StorageAccountName `
        --resource-group $ResourceGroupName `
        --location $Location `
        --sku Standard_LRS | Out-Null
} else {
    Write-Host "Using existing storage account: $StorageAccountName"
}

# --- Get access key ---
$AccountKey = az storage account keys list `
    --resource-group $ResourceGroupName `
    --account-name $StorageAccountName `
    --query "[0].value" -o tsv

# --- Create container ---
Write-Host "Ensuring container '$ContainerName' exists..."
az storage container create `
    --name $ContainerName `
    --account-name $StorageAccountName `
    --account-key $AccountKey | Out-Null

# --- Generate backend.tf ---
$BackendFile = "backend.tf"
$BackendContent = @"
terraform {
  backend "azurerm" {
    resource_group_name  = "$ResourceGroupName"
    storage_account_name = "$StorageAccountName"
    container_name       = "$ContainerName"
    key                  = "terraform.tfstate"
  }
}
"@

$BackendContent | Out-File -FilePath $BackendFile -Encoding utf8
Write-Host "Generated backend.tf successfully."

# --- Initialize Terraform backend ---
Write-Host "Initializing Terraform backend..."
terraform init -reconfigure | Out-Host

# --- Summary ---
Write-Host ""
Write-Host "================== Terraform Backend Info =================="
Write-Host "Resource Group      : $ResourceGroupName"
Write-Host "Storage Account     : $StorageAccountName"
Write-Host "Container           : $ContainerName"
Write-Host "State File Key      : terraform.tfstate"
Write-Host "==========================================================="