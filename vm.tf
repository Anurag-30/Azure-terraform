resource "azurerm_resource_group" "res_grp" {
  name     = "mainResourceGroup"
  location = "West US"

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
  location = "${azurerm_virtual_network.main.location}"
  name = "test-nic"
  resource_group_name = "${azurerm_resource_group.res_grp.name}"
  ip_configuration {
    name = "test-config"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_virtual_machine" "test"{
  name                  = "test-vm"
  location              = "${azurerm_resource_group.res_grp.location}"
  resource_group_name   = "${azurerm_resource_group.res_grp.name}"
  network_interface_ids = ["${azurerm_network_interface.network_interface.id}"]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "Centos"
    sku       = "CentOS-based 7.7"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}