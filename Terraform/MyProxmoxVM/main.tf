terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.33.0"
    }
  }
}



/*
resource "proxmox_virtual_environment_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "local"
  node_name    = var.pve_node_name

  source_file {
    path = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  }
}
*/

resource "proxmox_virtual_environment_file" "debian_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.pve_node_name
  source_raw {
    file_name = "qemu-agent.deb.cloud-config.yaml"
    data      = <<EOF
#cloud-config
runcmd:
  - apt update
  - apt install -y qemu-guest-agent net-tools
  - timedatectl set-timezone America/Toronto
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - echo "done" > /tmp/vendor-cloud-init-done
allow_public_ssh_keys: true

EOF
  }

}

resource "proxmox_virtual_environment_file" "el_cloud_config" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.pve_node_name
  source_raw {
    file_name = "qemu-agent.el.cloud-config.yaml"
    data      = <<EOF
#cloud-config
runcmd:
  - dnf update
  - dnf install -y qemu-guest-agent net-tools
  - timedatectl set-timezone America/Toronto
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - echo "done" > /tmp/vendor-cloud-init-done
allow_public_ssh_keys: true

EOF
  }

}

data "local_file" "ssh_public_key" {
  filename = var.automation.public_key
}


resource "proxmox_virtual_environment_vm" "vm" {
  node_name = var.pve_node_name
  name      = var.vm_name
  bios      = "ovmf"
  vm_id     = var.vm_id
  cpu {
    type  = "host"
    cores = 4
    units = 100
    numa  = true
  }
  clone {
    vm_id = var.vm_clone_id
  }
  disk {
    # datastore_id = data.proxmox_virtual_environment_datastores.proxmox01.datastore_id
    datastore_id = "PM863A"
    interface    = "virtio0"
    size         = 12
    file_format  = "raw"
  }
  agent {
    enabled = true
    type    = "virtio"
  }
  # efi_disk {
  # datastore_id = "PM863A"
  # type         = "4m"
  # file_format  = "raw"
  # pre_enrolled_keys = true
  # }
  started = true

  reboot = true

  initialization {
    interface           = "scsi0"
    vendor_data_file_id = proxmox_virtual_environment_file.el_cloud_config.id
    user_account {
      username = var.automation.username
      password = "supersecurepassword"
      keys = [
        data.local_file.ssh_public_key.content,
        "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDKbAZtdr5l2QJ1Ipo8tZM6aJDT4i2vKG7nDqbpoogV6yKOqvqkRM37tWnXYnDK0gP9boc3k1VMkIq6NKe4wTNA= debianwsl"
      ]
    }
    ip_config {
      ipv4 {
        address = "dhcp"
        # address = "192.168.101.236/24"
        # gateway = "192.168.101.1"
      }
    }

  }

  serial_device {}

  machine = "pc-q35-8.0"

  memory {
    dedicated = 2048
  }

  network_device {
    bridge      = "vmbr0"
    mac_address = var.vm_mac
  }

  operating_system {
    type = "l26"
  }

  vga {
    enabled = true
    type    = "serial0"
  }

  connection {
    host        = element(element(self.ipv4_addresses, index(self.network_interface_names, "eth0")), 0)
    type        = "ssh"
    user        = "webtroter"
    private_key = file("/home/webtroter/.ssh/id_ecdsa_local")
  }
  provisioner "remote-exec" {
    inline = ["whoami", "sleep 100"]
  }
  provisioner "local-exec" {
    command    = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u webtroter -i '${element(element(self.ipv4_addresses, index(self.network_interface_names, "eth0")), 0)},' --private-key '/home/webtroter/.ssh/id_ecdsa_local' ./Ansible/LibreNMS.playbook.yaml"
    on_failure = continue

  }
}

