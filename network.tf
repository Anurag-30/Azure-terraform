resource "azurerm_resource_group" "res_grp" {
  name     = "mainResourceGroup"
  location = "Central US"

  tags = {
    environment = "test"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "test-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.res_grp.location}"
  resource_group_name = "${azurerm_resource_group.res_grp.name}"
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = "${azurerm_resource_group.res_grp.name}"
  virtual_network_name = "${azurerm_virtual_network.main.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "network_interface" {
  location = "Central US"
  name = "test-nic"
  resource_group_name = "${azurerm_resource_group.res_grp.name}"
  ip_configuration {
    name = "test-config"
    subnet_id = "${azurerm_subnet.internal.id}"
    private_ip_address_allocation = "dynamic"
  }
}
