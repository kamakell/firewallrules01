#terraform {
 # backend "gcs" {
  #  bucket  = "abc"
   # prefix  = "terraform/state"
  #}
#}
// Configure the Google Cloud provider
#provider "google" {
 # credentials = "${file("${var.credentials}")}"
 #project     = "${var.gcp_project}"
 #region      = "${var.region}"
#}
// Create VPC
resource "google_compute_network" "vpc02" {
 name                    = "${var.network}-vpc02"
 auto_create_subnetworks = "false"
 count = "${var.google_compute_network}"
}

// Create Subnet
resource "google_compute_subnetwork02" "public" {
 name          = "${var.network}-public"
 description   = "This subnet is Public Subnetwork"
 ip_cidr_range = "${var.public_cidr02}"
 network       = "${var.network}-vpc"
 depends_on    = [google_compute_network.vpc]
 region      = "${var.region}"
 private_ip_google_access = "${var.private_google_access}"
 }

resource "google_compute_subnetwork02" "private" {
 name          = "${var.network}-private"
 ip_cidr_range = "${var.secondary_subnet_cidr02}"
 network       = "${var.network}-vpc"
 depends_on    = [google_compute_network.vpc]
 region      = "${var.region}"
}

// VPC Route Configuration
// resource "google_compute_route" "route-igw" {
//   name         = "route-igw"
//   dest_range   = "${var.igw}"
//   depends_on    = [google_compute_network.vpc]
//   network      = "${var.network}-vpc"
//   next_hop_ip = "${var.hop}"
//   priority     = "${var.priority}"
// }
// VPC firewall configuration
// resource "" "firewall" {
//   name    = "${var.network}-firewall"
//   network = "${google_compute_network.vpc.name}"

//   allow {
//     protocol = "icmp"
//   }

//   allow {
//     protocol = "tcp"
//     ports    = ["22"]
//   }

//   source_ranges = ["0.0.0.0/0"]
// }

resource "google_compute_firewall02" "ssh" {
  name    = "${var.network}-firewall-ssh"
  network      = "${var.network}-vpc"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["${var.network}-firewall-ssh"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall02" "http" {
  name    = "${var.network}-firewall-http"
  network      = "${var.network}-vpc"
  enable_logging = "true"
  priority = "1010"
  source_ranges = ["0.0.0.0/0"]
  source_service_accounts = ["kpa-sa01@vf-grp-pcs-tst-sandbox01.iam.gserviceaccount.com"]
   allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_service_accounts  = ["kpa-sa01@vf-grp-pcs-tst-sandbox01.iam.gserviceaccount.com"]
   allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall02" "abcd" {
  name    = "${var.network}-firewall-abcd"
  network      = "${var.network}-vpc"
  enable_logging = "true"
  priority = "1020"
  target_tags = ["vcd"]
  source_tags = ["abc"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
