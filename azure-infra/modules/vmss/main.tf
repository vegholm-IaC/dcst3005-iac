terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

resource "azurerm_windows_virtual_machine_scale_set" "vmss" {
  name                = var.vmss_name
  resource_group_name = var.rg_name
  location            = var.location
  sku                 = "Standard_F2"
  instances           = 2
  admin_username      = "tfadmin"
  admin_password      = "Bytt-meg-1234!"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter-Server-Core"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "internal"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id
    }
  }
}