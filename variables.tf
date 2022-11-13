variable "project_id" {
  description = "Google Cloud Project ID."
  type        = string
}

variable "region" {
  description = "Region name."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zone name."
  type        = string
  default     = "us-central1-f"
}

variable "name" {
  description = "Web server name."
  type        = string
  default     = "my-webserver"
}

variable "machine_type" {
  description = "GCE VM instance machine type."
  type        = string
  default     = "f1-micro"
}

variable "labels" {
  description = "List of labels to attach to the VM instance."
  type        = map
}
