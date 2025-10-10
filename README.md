# 🌍 EpicBook — Full Stack Web App on Azure with Terraform

EpicBook is a sample full-stack web application deployed on **Microsoft Azure** using **Terraform** for infrastructure-as-code and **Node.js** for the application backend.

The project provisions a complete cloud environment — including networking, database, compute, and automatic app deployment — all managed through Terraform.

---

## 🚀 Features

- **Automated Infrastructure** — Azure infrastructure created with Terraform  
- **Environment Separation** — Supports `dev` and `prod` workspaces  
- **Azure MySQL Flexible Server** for database  
- **Azure Linux VM** hosting the Node.js web server  
- **Cloud-init Automation** for app deployment  
- **Nginx Reverse Proxy** with port forwarding to the Node app  
- **Secure Configuration** via `.env` and Terraform variables  

---

## 🏗️ Infrastructure Overview

Terraform creates the following Azure resources:

| Component | Description |
|------------|--------------|
| Resource Group | Logical container for all resources |
| Virtual Network + Subnets | Separate public & MySQL subnets |
| Network Security Group | Restricts inbound traffic |
| MySQL Flexible Server | Backend database |
| Linux Virtual Machine | Hosts the Node.js app |
| Public IP + Nginx | Exposes the web app to the internet |

---

## 🧱 Project Structure

```bash
epicbook-terraform/
├── main.tf                  # Root module orchestrating resources
├── variables.tf             # Input variables
├── outputs.tf               # Outputs (IP, URLs, etc.)
├── cloud-init.tpl           # User data for VM app setup
├── envs/
│   ├── dev.tfvars           # Development environment config
│   └── prod.tfvars          # Production environment config
├── modules/
│   ├── network/             # VNet, subnets, NSG
│   ├── database/            # MySQL flexible server
│   └── compute/             # Linux VM + App deployment
└── README.md
```

---

## ⚙️ Prerequisites

- [Terraform ≥ 1.0](https://developer.hashicorp.com/terraform/downloads)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- A valid Azure subscription
- SSH key pair (public + private)

---

## 🔑 Setup Steps

### 1️⃣ Clone the Repositories

```bash
git clone https://github.com/blessedsoft/theepicbook.git
git clone https://github.com/blessedsoft/epicbook-terraform-full.git
cd epicbook-terraform-full
```

### 2️⃣ Authenticate with Azure

```bash
az login
```

### 3️⃣ Initialize Terraform

```bash
terraform init
```

### 4️⃣ Select or Create Workspace

```bash
terraform workspace new dev   # or prod
terraform workspace select dev
```

### 5️⃣ Plan Infrastructure

```bash
terraform plan -var-file="envs/dev.tfvars"
```

### 6️⃣ Apply Infrastructure

```bash
terraform apply -var-file="envs/dev.tfvars" -auto-approve
```

---

## 🧠 Cloud-Init Explained

The **`cloud-init.tpl`** file configures the VM at first boot:

- Installs Node.js, Nginx, Git, MySQL client  
- Clones the [EpicBook app repo](https://github.com/blessedsoft/theepicbook)  
- Creates an `.env` file with DB credentials  
- Runs `npm install` and starts the app as a **systemd service**  
- Configures Nginx to reverse proxy traffic to the Node app on port `3000`

---

## 🌐 Access the App

Once `terraform apply` completes, check the output:

```bash
Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

Outputs:
app_public_ip = "x.x.x.x"
db_host = "epicbook-mysql-dev.mysql.database.azure.com"
```

Now open your browser and visit:

```
http://x.x.x.x
```

---

## 🧰 Useful Commands

| Command | Description |
|----------|-------------|
| `terraform fmt` | Format Terraform code |
| `terraform validate` | Validate syntax |
| `terraform workspace list` | View environments |
| `terraform destroy -var-file="envs/dev.tfvars"` | Tear down environment |

---

## 🔐 Security Notes

- Never commit `.tfvars`, `.env`, or passwords to GitHub  
- Use Azure Key Vault or environment variables for secrets  
- Use SSH keys for secure VM access  
- Restrict `allowed_ip` to your public IP address

---

## 🧹 Cleanup

When done testing, destroy all resources to avoid charges:

```bash
terraform destroy -var-file="envs/dev.tfvars" -auto-approve
```

---

## 👨‍💻 Author

**Blessedsoft DevOps**  
📧 olajidesolomon11@gmail.com  
🌐 [https://github.com/blessedsoft](https://github.com/blessedsoft)

---

## 📝 License

This project is licensed under the **MIT License** — feel free to modify and use it for learning or deployments.