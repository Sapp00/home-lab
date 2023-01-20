variable "cluster_name" {
    type = string
    default = "talos-cluster"
}

variable "qemu_guest_agent" {
  default = 0
}

variable "iso_image_location" {
    description = "The location of the Talos iso image on the proxmox host (<storage pool>:<content type>/<file name>.iso)."
    type = string
    default = "local:iso/talos-amd64.iso"
}

variable "network_bridge" {
    description = "The name of the network bridge on the Proxmox host that will be used for the configuration network."
    type = string
    default = "vmbr0"
}

variable "proxmox_debug" {
    description = "If the debug flag should be set when interacting with the Proxmox API."
    type = bool
    default = false
}

variable "boot_disk_storage_pool" {
    description = "The name of the storage pool where boot disks for the cluster nodes will be stored."
    type = string
    default = "local-lvm"
}

variable "boot_disk_size" {
    description = "The size of the boot disks. A numeric string with G, M, or K appended ex: 512M or 32G."
    type = string
    default = "32G"
}

variable "persistent_disk_size" {
    description = "The size of the persistent storage. A numeric string with G, M, or K appended ex: 512M or 32G."
    type = string
    default = "32G"
}