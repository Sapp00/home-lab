resource "proxmox_vm_qemu" "talos-control-plane-node" {
    for_each    = nonsensitive(toset(keys( jsondecode(data.sops_file.secs.raw).masters)))
    name        = "${var.cluster_name}-${  jsondecode(data.sops_file.secs.raw).masters[ each.value ].name}"
 #   iso         = var.iso_image_location
    clone       = jsondecode(data.sops_file.secs.raw).masters[ each.value ].template
    full_clone  = true
    target_node = jsondecode(data.sops_file.secs.raw).masters[ each.value ].pve-node
    vmid        = each.key
    qemu_os     = "l26" # Linux kernel type
    memory      = "3072"
    cpu         = "kvm64"
    cores       = 2
    sockets     = 1
    numa        = false
    hotplug     = "network,disk,usb"
    scsihw      = "virtio-scsi-single"
    network {
        model  = "virtio"
        bridge = var.network_bridge
        tag    = data.sops_file.secs.data["vlan"]
        macaddr = jsondecode(data.sops_file.secs.raw).masters[ each.value ].macaddr
    }
    disk {
        type    = "virtio"
        size    = var.boot_disk_size
        storage = var.boot_disk_storage_pool
    }
    onboot      = true
    agent       = var.qemu_guest_agent
    #args        = "-cpu kvm64,+cx16,+lahf_lm,+popcnt,+sse3,+ssse3,+sse4.1,+sse4.2"
}
