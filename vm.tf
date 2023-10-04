terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.33.0"
    }
  }
}

variable "pve_node_password" {
  type        = string
  description = "Password of pvenode"
}
variable "pve_node_user" {
  type        = string
  description = "Password of pvenode"
}
variable "pve_node_name" {
  type        = string
  description = "Password of pvenode"
}
variable "pve_node_address" {
  type        = string
  description = "Password of pvenode"
}

variable "pve_cluster_user" {
  type        = string
  description = "User of PVE Cluster"
}
variable "pve_cluster_password" {
  type        = string
  description = "User of PVE Cluster"
}
variable "pve_cluster_endpoint" {
  type        = string
  description = "endpoint of PVE Cluster"
}
variable "pve_cluster_api_token" {
  type        = string
  description = "api_token of PVE Cluster"
}

variable "vm_id" {
  type        = number
  description = "VM Id"
}
variable "vm_name" {
  type        = string
  description = "VM Name"
  default     = "vm"
}

variable "vm_clone_id" {
  type        = number
  description = "VM ID to clone. VM with RockyLinux genericcloud image deployed on"
}

provider "proxmox" {
  # Configuration options
  endpoint = var.pve_cluster_endpoint
  username = var.pve_cluster_user
  # password = "the-password-set-during-installation-of-proxmox-ve"
  insecure  = true
  api_token = var.pve_cluster_api_token
  ssh {
    agent    = true
    username = var.pve_node_user
    node {
      address = var.pve_node_address
      name    = var.pve_node_name
    }
  }
  password = var.pve_cluster_password

}

module "vm01" {
  source = "./Terraform/MyProxmoxVM"

  automation = {
    private_key = "/home/webtroter/.ssh/id_ecdsa_local"
    public_key  = "/home/webtroter/.ssh/id_ecdsa_local.pub"
    username    = "webtroter"
  }

  vm_id   = var.vm_id
  vm_name = var.vm_name
  vm_mac  = null

  vm_clone_id = 9933

  # vm_mac = "12:0A:F9:DE:89:AD"

  # pve_cluster_user      = var.pve_cluster_user
  # pve_cluster_password  = var.pve_cluster_password
  # pve_cluster_endpoint  = var.pve_cluster_endpoint
  # pve_cluster_api_token = var.pve_cluster_api_token
  # pve_node_name         = var.pve_node_name
  # pve_node_address      = var.pve_node_address
  # pve_node_user         = var.pve_node_user
  # pve_node_password     = var.pve_node_password

}

/* # Useless this.

resource "terraform_data" "vm" {
  provisioner "local-exec" {
    command    = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u admin -i '${element(element(module.vm01.vm.ipv4_addresses, index(module.vm01.vm.network_interface_names, "eth0")), 0)},' --private-key '/home/webtroter/.ssh/id_ecdsa_local' ./Ansible/tmux-install.playbook.yml"
    on_failure = continue
  }
}
 */
