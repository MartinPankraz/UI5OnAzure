variable "prefix" {
  type = string
}

variable "location" {
  type = string
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