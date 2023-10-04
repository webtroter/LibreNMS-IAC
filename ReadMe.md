
Everything I need to deploy LibreNMS on Podman on a RockyLinux Template on Proxmox


# Some prerequesites

- Terraform
- Ansible
- Ansible Collections
  - containers.podman
  - community.general

- A RockyLinux genericcloud *template* VM


# Deployment Process

1. Terraform
  1.1.  Copy vars.auto.tfvars.bak to vars.auto.tfvars
  1.2.  Fill the vars.auto.tfvars
  1.3.  `terraform apply`

Terraform will deploy the VM, and call ansible-playbook on it.
This uses a local-provider to call ansible-playbook. 
Before that, there is a remote-provider that will connect to the VM via SSH and
  sleep 120 seconds over there, to let cloud-init finish before running ansible.


2. Initial Configuration of LibreNMS
  2.1 Connect to LibreNMS IP:8000 immediately when terraform finishes and complete the initial configure of LibreNMS
      I don't know why, but if you don't act fast, the pod will stop and you won't be able to set the initial LibreNMS user after that.
  2.2 When this initial configuration is done, restart the LibreNMS pod : `podman pod restart LibreNMS`
      This seems to sync the dispatcher-sidecar
  2.3 Configure the rest
      - SNMP
      - Poller frequency AND RRD steps
  2.4 Add some devices

## About the Ansible Playbook and roles

### Podman Role

The Podman COPR Repo is added so we can install a recent podman version.
It should be possible to skip by commenting the tag `podman_fromcopr`, in the second task *Podman Install* of the first play *Install Podman*

### LibreNMS Role

The role sets everything so that we can run the podman containers.

Including the SELinux stuff and the permissions on the `/opt/LibreNMS` directory.

I set some fixed MCS categories on the `db/` directory so that only the mariadb container can access. I used `s0:c33,c306`
This is hardcoded the the kubeplay and role.

# Troubleshooting

Good luck.

There are some commands you can use on the VM in [tools/notes.md](tools/notes.md)
