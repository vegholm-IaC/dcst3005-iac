terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

resource "azurerm_network_interface" "nic" {
  name                = lower("NIC-${var.base_name}")
  location            = var.location
  resource_group_name = lower(var.rsg_name)

  ip_configuration {
    name                          = lower("ip-config-${var.base_name}")
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
  tags = local.common_tags
}

resource "azurerm_virtual_machine" "vm" {
  name                  = lower("VM-${var.base_name}")
  location              = var.location
  resource_group_name   = lower(var.rsg_name)
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = var.vm_size

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  # delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
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
  tags                          = local.common_tags
  delete_os_disk_on_termination = true
}