terraform {
  required_providers {
    sops = {
      source = "carlpett/sops"
      version = "~> 0.5"
    }
    proxmox = {
      source = "Telmate/proxmox"
      version = ">= 2.9.10"
    }
  }
}

/*
terraform {
  backend "remote" {
    organization = "home-env"
    workspaces {
      name = "homecluster-local"
    }
  }
}*/

data "sops_file" "secs" {
  source_file = "secrets.sops.json"
}

provider "proxmox" {
  pm_tls_insecure = true
  pm_api_token_secret = data.sops_file.secs.data["token"]
  pm_api_token_id = data.sops_file.secs.data["id"]
  pm_api_url      = format("%s:%s%s", data.sops_file.secs.data["url"], data.sops_file.secs.data["port"], "/api2/json")
  pm_debug        = true
  pm_parallel     = 25
}



variable "pve-id" {
  type  = string
  default = null
}



output "pve-id-out" {
  # Access the password variable that is under db via the terraform map of data
  value = format("%s:%s%s", data.sops_file.secs.data["url"], data.sops_file.secs.data["port"], "/api2/json")
  sensitive = true
}

output "pve-token" {
  # Access the password variable that is under db via the terraform map of data
  value = data.sops_file.secs.data["token"]
  sensitive = true
}
