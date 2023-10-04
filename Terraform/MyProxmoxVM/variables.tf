variable "vm_id" {
  type        = number
  description = "VM Id"
}
variable "vm_name" {
  type        = string
  description = "VM Name"
  default     = "vm"
}

variable "vm_mac" {
  type        = string
  description = "MAC Address"
  nullable    = true
  # default     = null
}

variable "vm_clone_id" {
  type        = number
  description = "VM ID to clone. VM with RockyLinux genericcloud image deployed on"
}

variable "automation" {
  type = object({
    private_key = string
    public_key  = string
    username    = string
  })
  default = {
    private_key = "~/.ssh/id_rsa"
    public_key  = "~/.ssh/id_rsa.pub"
    username    = "webtroter"
  }
}

variable "pve_node_name" {
  type        = string
  default     = "proxmox01"
  description = "PVE Cluster Node Name"
}

/*

variable "pve_info" {
  type = object({
    cluster_endpoint = string
    nodes = list(object({
      name    = string
      address = string
    }))
  })
  default = {
    cluster_endpoint = "https://192.168.101.61:8006/"
    nodes = [{
      address = "192.168.101.61"
      name    = "proxmox01"
    }]
  }
  description = "PVE Info"

}

*/

/*

variable "pve_node_password" {
  type        = string
  description = "Password of pvenode"
}
variable "pve_node_user" {
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

*/
