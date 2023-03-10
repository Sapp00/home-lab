resource "proxmox_vm_qemu" "talos-worker-node" {
    for_each    = nonsensitive(toset(keys( jsondecode(data.sops_file.secs.raw).workers)))
    name        = "${var.cluster_name}-${  jsondecode(data.sops_file.secs.raw).workers[ each.value ].name}"
 #   iso         = var.iso_image_location
    clone       = jsondecode(data.sops_file.secs.raw).workers[ each.value ].template
    full_clone  = true
    target_node = jsondecode(data.sops_file.secs.raw).workers[ each.value ].pve-node
    vmid        = each.key
    qemu_os     = "l26" # Linux kernel type
    memory      = "5120"
    cpu         = "kvm64"
    cores       = 4
    sockets     = 1
    numa        = false
    hotplug     = "network,disk,usb"
    scsihw      = "virtio-scsi-single"
    network {
        model  = "virtio"
        bridge = var.network_bridge
        tag    = data.sops_file.secs.data["vlan"]
        macaddr = jsondecode(data.sops_file.secs.raw).workers[ each.value ].macaddr
    }
    disk {
        type     = "scsi"
        size     = var.boot_disk_size
        storage  = var.boot_disk_storage_pool
        format   = "raw"
    }
    disk {
        type     = "scsi"
        size     = var.persistent_disk_size
        storage  = var.boot_disk_storage_pool
        format   = "raw"
        iothread = 1
    }
    onboot      = true
    agent       = var.qemu_guest_agent
    #args        = "-cpu kvm64,+cx16,+lahf_lm,+popcnt,+sse3,+ssse3,+sse4.1,+sse4.2"
}