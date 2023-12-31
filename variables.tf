variable "subscription_id" {
  description = "Subscription Id"
  type        = string
}

variable "client_id" {
  description = "Client Id"
  type        = string
}

variable "client_secret" {
  description = "Client Secret"
  type        = string
}

variable "object_id" {
  description = "Object Id"
  type        = string
}

variable "tenant_id" {
  description = "Tenant Id"
  type        = string
}

variable "company" {
  description = "Integity Vision"
  type        = string
}

variable "client" {
  description = "Client company name"
  type        = string
}

variable "environment" {
  description = "Environment: Dev, Test, Stage, Prod"
  type        = string
}

variable "location" {
  description = "The geographic location of the resources"
  type        = string
}

##### Azure Kubernetes Service #####
variable "aks_cluster_name" {
  description = "Azure Kubernetes Cluster name"
  type        = string
}