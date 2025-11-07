location                = "southeastasia"
resource_group_name     = "dmi-epicbook-rg"
admin_username          = "azureuser"
ssh_public_key_path     = "~/.ssh/azure_rsa.pub"
vm_size                 = "B_Standard_B1ms"
db_username             = "devepicuser"
db_password             = "DevStrongPassword123!"
my_ip                   = "0.0.0.0/0"
tags = {
  environment = "dev"
}