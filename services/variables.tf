variable "subscription_id" {
  type        = string
}

variable "client_id" {
  type        = string
}

variable "object_id" {
  type        = string
}

variable "tenant_id" {
  type        = string
}

##### Local Resources #####
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "environment" {
  type = string
}
variable "aks_cluster_name" {
  type = string
}