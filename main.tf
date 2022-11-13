terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.43.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = "us-west1-a"
}

# Cloud IDS
resource "google_compute_network" "my_network" {
    name = "my-network"
}
resource "google_compute_global_address" "service_range" {
    name          = "address"
    purpose       = "VPC_PEERING"
    address_type  = "INTERNAL"
    prefix_length = 16
    network       = google_compute_network.my_network.id
}
resource "google_service_networking_connection" "private_service_connection" {
    network                 = google_compute_network.my_network.id
    service                 = "servicenetworking.googleapis.com"
    reserved_peering_ranges = [google_compute_global_address.service_range.name]
}

resource "google_cloud_ids_endpoint" "example-endpoint" {
    name     = "test"
    location = var.zone
    network  = google_compute_network.my_network.id
    severity = "INFORMATIONAL"
    depends_on = [google_service_networking_connection.private_service_connection]
}

# Sample targets
data "google_compute_image" "debian" {
  family  = "ubuntu-minimal-2204-lts"
  project = "ubuntu-os-cloud"
}

# Creates a GCP VM Instance.
resource "google_compute_instance" "vm" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["http-server"]
  labels       = var.labels

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian.self_link
    }
  }

  network_interface {
    network = google_compute_network.my_network.id
    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = data.template_file.nginx.rendered
}

data "template_file" "nginx" {
  template = "${file("${path.module}/template/install_nginx.tpl")}"

  vars = {
    ufw_allow_nginx = "Nginx HTTP"
  }
}
