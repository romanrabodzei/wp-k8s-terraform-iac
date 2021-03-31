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


##### Virtual   Network #####
variable "aks_subnet_name" {
  description = "Dedicated subnet for Azure Kubernetes Cluster"
  type        = string
}

variable "aks_subnet_address" {
  description = "Address range for the subnet"
  type        = string
}

variable "srv_subnet_name" {
  description = "Dedicated subnet for SQL databases and services"
  type        = string
}

variable "srv_subnet_address" {
  description = "Address range for the subnet"
  type        = string
}