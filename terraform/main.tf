terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# Base volume
resource "libvirt_volume" "ubuntu_base" {
  name = "base.qcow2"
  pool = "default"

  create = {
    content = {
      url = "noble-server-cloudimg-amd64.img"
    }
  }

  target = {
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_volume" "ubuntu_disk" {
  name          = "disk.qcow2"
  pool          = "default"
  capacity      = 10737418240
  capacity_unit = "bytes"

  target = {
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_cloudinit_disk" "init" {
  name           = "cidata.iso"
  user_data      = file("${path.module}/user-data")
  meta_data      = file("${path.module}/meta-data")
  network_config = file("${path.module}/network-config")
}

resource "libvirt_volume" "cloudinit" {
  name = "cidata.iso"
  pool = "default"
  target = {
    format = {
      type = "raw"
    }
  }

  create = {
    content = {
      url = libvirt_cloudinit_disk.init.path
    }
  }
}

# Basic VM configuration
# Based on the default XML configuration provided by Virtual Machine Manager
resource "libvirt_domain" "ubuntu_vm" {
  name        = "example-vm"
  memory      = 2048
  memory_unit = "MiB"
  vcpu        = 2
  type        = "kvm"
  running     = true

  cpu = {
    mode = "host-passthrough"
  }

  features = {
    acpi = true
    apic = {}
    vm_port = {
      state = "off"
    }
  }

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
    boot_devices = [{
      dev = "hd"
    }]
  }

  devices = {
    disks = [
      {
        source = {
          file = {
            file = libvirt_volume.ubuntu_disk.path
          }
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
        driver = {
          type = "qcow2"
        }
        backing_store = {
          source = {
            file = {
              file = libvirt_volume.ubuntu_base.path
            }
          }
          format = {
            type = "qcow2"
          }
        }
      },
      {
        source = {
          file = {
            file = libvirt_volume.cloudinit.path
          }
        }
        target = {
          dev = "sdb"
          bus = "sata"
        }
        driver = {
          type = "raw"
        }
        device    = "cdrom"
        read_only = true
      }
    ]

    interfaces = [
      {
        model = {
          type = "virtio"
        }
        source = {
          network = {
            network = "default"
          }
        }
      },
    ]
    graphics = [{
      spice = {
        auto_port = true
        listen    = "127.0.0.1"
        image = {
          compression = "off"
        }
      }
    }]

  }
}
