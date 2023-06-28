# Input variable definitions

variable "rgname" {
    default = "jenoptik-rg"
    type = string
    description = "This is the name of resource group."
  
}

variable "location" {
    default = "Germany West Central"
    type = string
    description = "This is the location of Resources."
  
}


variable "nsgname" {
    default = "jenoptik-nsg"
    type = string
    description = "This is the name of Network_Security_Group for Resources"
  
}


variable "vnet" {
    default = "jenoptik-vnet"
    type = string
    description = "This is the name of Virtual_Network for Resources and Application Services."
  
}


variable "app-service-plan" {
    default = "jenoptik-app-service-plan"
    type = string
    description = "This is app_service-plan."
  
}


variable "app-service" {
    default = "jenoptik-app-service"
    type = string
    description = "This is the name of App-Service."
  
}


variable "ad-app" {
    default = "jenoptik-active-directory"
    type = string
    description = "This is the name of active-directory_app."
  
}


variable "app_gateway" {
    default = "jenoptik-app-gateway"
    type = string
    description = "This is the name of App-gateway"
  
}


variable "storage" {
    default = "jenoptik-storage"
    type = string
    description = "This is the Storage for application."
  
}


variable "sql-server" {
    default = "jenoptik-sql-server"
    type = string
    description = "This is the name of sql-server for the purpose of database."
  
}

