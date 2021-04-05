/*##### Remote resources #####
variable "remote_resource_group_name" {
  type = string
}
variable "remote_virtual_network_name" {
  type = string
}
variable "remote_virtual_network_id" {
  type = string
}
*/


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
variable "srv_subnet_name" {
  type = string
}
variable "srv_subnet_address" {
  type = string
}
variable "aks_subnet_name" {
  type = string
}
variable "aks_subnet_address" {
  type = string
}

variable "aks_cluster_name" {
  type = string
}

variable "sql_administrator_login" {
  type = string
}

variable "sql_administrator_login_password" {
  type = string
}