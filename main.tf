# Provider Requirements
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# create a resource group
resource "azurerm_resource_group" "rgname" {
  name     = "${var.rgname}"
  location = "${var.location}"
}

# Create Network Security Group
resource "azurerm_network_security_group" "nsgname" {
  name                = "${var.nsgname}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rgname.name}"
}

# Create Virtual-network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet}"
  location            = "${azurerm_resource_group.location.location}"
  resource_group_name = "${azurerm_resource_group.rgname.name}"
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}


# Create AppService plan
resource "azurerm_app_service_plan" "app-service-zenoptik-plan" {
  name                = "${var.app-service-zenoptik-plan}"
  location            = "${azurerm_resource_group.app-service-zenoptik-plan.location}"
  resource_group_name = "${azurerm_resource_group.rgname.name}"

  sku {
    tier = "Standard"
    size = "S1"
  }
}

# Create AppService
resource "azurerm_app_service" "app-service-zenoptik" {
  name                = "${var.app-service-zenoptik}"
  location            = "${azurerm_resource_group.location.location}"
  resource_group_name = "${azurerm_resource_group.rgname.name}"
  app_service_plan_id = "${azurerm_app_service_plan.app-service-zenoptik.id}"

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}

# Create Active Directory application
resource "azurerm_azuread_application" "Zenoptik__ad_app" {
  name                       = "${var.Zenoptik__ad_app}"
  homepage                   = "https://homepage"
  identifier_uris            = ["https://uri"]
  reply_urls                 = ["https://replyurl"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}

//
resource "azurerm_azuread_application" "example" {
  name                       = "example"
  homepage                   = "http://homepage"
  identifier_uris            = ["http://uri"]
  reply_urls                 = ["http://replyurl"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}
//

//
resource "azurerm_azuread_service_principal" "example" {
  application_id = "${azurerm_azuread_application.example.application_id}"
}
//

//
resource "azurerm_azuread_application" "example" {
  name                       = "example"
  homepage                   = "https://homepage"
  identifier_uris            = ["https://uri"]
  reply_urls                 = ["https://replyurl"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}
//

# Create Azure Active Directory Service Principal
resource "azurerm_azuread_service_principal" "example" {
  application_id = "${azurerm_azuread_application.example.application_id}"
}

resource "azurerm_azuread_service_principal_password" "example" {
  service_principal_id = "${azurerm_azuread_service_principal.example.id}"
  value                = "VT=uSgbTanZhyz@%nL9Hpd+Tfay_MRV#"
  end_date             = "2020-01-01T01:02:03Z"
}


# Create Azure Subnet for Frontend 
resource "azurerm_subnet" "frontend" {
  name                 = "frontend"
  resource_group_name  = "${azurerm_resource_group.example.name}"
  virtual_network_name = "${azurerm_virtual_network.example.name}"
  address_prefix       = "10.254.0.0/24"
}

#Create Azure Subnet for Backend 
resource "azurerm_subnet" "backend" {
  name                 = "backend"
  resource_group_name  = "${azurerm_resource_group.example.name}"
  virtual_network_name = "${azurerm_virtual_network.example.name}"
  address_prefix       = "10.254.2.0/24"
}

# Azure Public IP Details-
resource "azurerm_public_ip" "example" {
  name                = "example-pip"
  resource_group_name = "${azurerm_resource_group.example.name}"
  location            = "${azurerm_resource_group.example.location}"
  allocation_method   = "Dynamic"
}


#&nbsp;since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${azurerm_virtual_network.example.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.example.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.example.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.example.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.example.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.example.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.example.name}-rdrcfg"
}


# This is Azure Application Gateway details-

resource "azurerm_application_gateway" "app_gateway" {
  name                = "${var.app_gateway}"
  resource_group_name = "${azurerm_resource_group.rgname.name}"
  location            = "${azurerm_resource_group.location.location}"

  //sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }
  //


  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = "${azurerm_subnet.frontend.id}"
  }

  frontend_port {
    name = "${local.frontend_port_name}"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "${local.frontend_ip_configuration_name}"
    public_ip_address_id = "${azurerm_public_ip.example.id}"
  }

  backend_address_pool {
    name = "${local.backend_address_pool_name}"
  }

  backend_http_settings {
    name                  = "${local.http_setting_name}"
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = "${local.listener_name}"
    frontend_ip_configuration_name = "${local.frontend_ip_configuration_name}"
    frontend_port_name             = "${local.frontend_port_name}"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "${local.request_routing_rule_name}"
    rule_type                  = "Basic"
    http_listener_name         = "${local.listener_name}"
    backend_address_pool_name  = "${local.backend_address_pool_name}"
    backend_http_settings_name = "${local.http_setting_name}"
  }

//
resource "azurerm_resource_group" "example" {
  name     = "database-rg"
  location = "West Europe"
  } 
//
}

# This is Azure Storage Account details-

resource "azurerm_storage_account" "Zenoptik_storage" {
  name                     = "${var.Zenoptik_storage}"
  resource_group_name      = azurerm_resource_group.rgname.name
  location                 = azurerm_resource_group.location.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# This is Azure SQL Server details-

resource "azurerm_sql_server" "Zenoptik_sql-server" {
  name                         = "${var.Zenoptik_sql-server}"
  resource_group_name          = azurerm_resource_group.rgname.name
  location                     = azurerm_resource_group.location.location
  version                      = "12.0"
  #administrator_login          = "mradministrator"
  #administrator_login_password = "thisIsDog11"

  tags = {
    environment = "production"
  }
}