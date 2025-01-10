variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The region for GCP resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The zone for the VM instance"
  type        = string
  default     = "us-central1-a"
}

variable "instance_name" {
  description = "The name of the VM instance"
  type        = string
}

variable "machine_type" {
  description = "The type of the VM instance"
  type        = string
  default     = "e2-medium"
}

variable "ssh_public_key" {
  description = "The public SSH key content"
  type        = string
}
