terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.15.0"
    }
  }
}
provider "google" {
  project = "tflabs"
  region  = "us-central1"
}

locals {
  vm_info = {
    "vm-instance-1" = {
      ip   = "10.128.0.20"
      zone = "us-central1-a"
    }
  }
}

resource "google_compute_address" "reserved_ip" {
  for_each     = local.vm_info
  name         = "reserved-ip-${each.key}"
  address_type = "INTERNAL"
  address      = each.value.ip
  region       = "us-central1"
  subnetwork   = "default"
}

resource "google_compute_instance" "vm_instance" {
  for_each    = local.vm_info
  name        = each.key
  machine_type = "n1-standard-1"
  zone        = each.value.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
    network_ip = google_compute_address.reserved_ip[each.key].address
  }
attached_disk {
    source = google_compute_disk.data_disk[each.key].self_link
}

metadata = {
    ssh-keys       = "vijay:${file("~/.ssh/id_rsa.pub")}"
    startup-script = <<-EOF
      #!/bin/bash
      DISK="/dev/sdb"
      MOUNT_POINT="/apps"

      # Create mount point directory if it doesn't exist
      mkdir -p $MOUNT_POINT

      # Check if disk has a filesystem
      if ! blkid $DISK > /dev/null 2>&1; then
        # No filesystem detected, create ext4
        mkfs.ext4 $DISK
      fi

      # Add to fstab if not already there
      if ! grep -q $DISK /etc/fstab; then
        echo "$DISK $MOUNT_POINT ext4 defaults 0 2" >> /etc/fstab
      fi

      # Mount the disk
      mount $MOUNT_POINT || mount -a

      # Set permissions for all users (777) on /apps
      chmod 777 $MOUNT_POINT
    EOF
}

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "vm_instance_public_ip" {
  value = {
    for vm in google_compute_instance.vm_instance : vm.name => vm.network_interface[0].access_config[0].nat_ip
  }
}

resource "google_compute_disk" "data_disk" {
  for_each = local.vm_info
  name = "data-disk-${each.key}"
  type = "pd-standard"
  zone = each.value.zone
  size = 20
}
