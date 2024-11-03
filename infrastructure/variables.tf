variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "Central India"
}

variable "environment" {
  description = "Environment name (dev, prod, etc.)"
  type        = string
  default     = "development"
}

variable "kubernetes_version" {
  description = "Version of Kubernetes for AKS cluster"
  type        = string
  default     = "1.27.7"
}

variable "sql_admin_username" {
  description = "Administrator username for Azure SQL Server"
  type        = string
}

variable "sql_admin_password" {
  description = "Administrator password for Azure SQL Server"
  type        = string
  sensitive   = true
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}