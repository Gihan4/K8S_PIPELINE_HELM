provider "google" {
  credentials = file("/var/lib/jenkins/.kube/credentials")
  project     = var.project_id
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "formidable-hold-392607"
}

variable "zone" {
  description = "Cluster Zone"
  type        = string
  default     = "us-central1-a"
}

resource "google_container_cluster" "test_cluster" {
  name               = "test-cluster"
  location           = var.zone
  initial_node_count = 1
}

resource "google_container_node_pool" "test_node_pool" {
  name       = "test-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.test_cluster.name
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 12
    disk_type    = "pd-standard"
  }
}

resource "google_container_cluster" "prod_cluster" {
  name               = "prod-cluster"
  location           = var.zone
  initial_node_count = 1
}

resource "google_container_node_pool" "prod_node_pool" {
  name       = "prod-node-pool"
  location   = var.zone
  cluster    = google_container_cluster.prod_cluster.name
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 12
    disk_type    = "pd-standard"
  }
}

output "project_id" {
  value       = var.project_id
  description = "GCP Project ID"
}

output "zone" {
  value       = var.zone
  description = "Test Cluster Zone"
}

output "test_cluster_name" {
  value       = google_container_cluster.test_cluster.name
  description = "Test Cluster Name"
}

output "test_cluster_host" {
  value       = google_container_cluster.test_cluster.endpoint
  description = "Test Cluster IP"
}

output "prod_cluster_name" {
  value       = google_container_cluster.prod_cluster.name
  description = "Prod Cluster Name"
}

output "prod_cluster_host" {
  value       = google_container_cluster.prod_cluster.endpoint
  description = "Prod Cluster IP"
}
