variable "prefix" {
  description = "prefix identifier"
}

variable "location" {
  description = "Azure Location to deploy to"
}

variable "docker_registry" {
  description = "domain of your Docker Registry (e.g. in Azure with ACR)"
}

variable "docker_registry_image_path" {
  description = "Path to your Docker Image in Docker Registry (e.g. in Azure with ACR)"
}

resource "azurerm_resource_group" "myrg" {
  name     = "${var.prefix}-resources"
  location = "${var.location}"
}

resource "azurerm_container_registry" "myrg" {
  name                = "${var.prefix}registry"
  resource_group_name = "${azurerm_resource_group.myrg.name}"
  location            = "${azurerm_resource_group.myrg.location}"
  sku                 = "Standard"
}

resource "azurerm_app_service_plan" "myrg" {
  name                = "${var.prefix}-asp"
  location            = "${azurerm_resource_group.myrg.location}"
  resource_group_name = "${azurerm_resource_group.myrg.name}"
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "PremiumV2"
    size = "P1v2"
  }
}

resource "azurerm_app_service" "myrg" {
  name                = "${var.prefix}-appservice"
  location            = "${azurerm_resource_group.myrg.location}"
  resource_group_name = "${azurerm_resource_group.myrg.name}"
  app_service_plan_id = "${azurerm_app_service_plan.myrg.id}"

  site_config {
    dotnet_framework_version = "v4.0"
    remote_debugging_enabled = true
    remote_debugging_version = "VS2015"
  }

  site_config {
    linux_fx_version = "DOCKER|${var.docker_registry}${var.docker_registry_image_path}"
  }

  app_settings = {
    "DOCKER_REGISTRY_SERVER_URL"          = "https://${var.docker_registry}"
  }
}

resource "azurerm_app_service_slot" "myrg" {
  name                = "${random_id.server.hex}"
  app_service_name    = "${azurerm_app_service.myrg.name}"
  location            = "${azurerm_resource_group.myrg.location}"
  resource_group_name = "${azurerm_resource_group.myrg.name}"
  app_service_plan_id = "${azurerm_app_service_plan.myrg.id}"

  site_config {
    dotnet_framework_version = "v4.0"
  }

}