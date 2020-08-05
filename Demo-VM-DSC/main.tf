provider "azurerm" {
  subscription_id = var.subid
  features {}
  version = "=2.17.0"
  }

resource "azurerm_resource_group" "rg" {
  name     = var.rgname
  location = "West Europe"

  tags = {
    project = var.costcenter
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "virtualNetwork1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.1.0.0/16"]

  tags = {
    project = var.costcenter
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.1.1.0/24"
}

# VMs West Europe

resource "azurerm_network_interface" "nic-vm1-name" {
  name                = "${var.vm1-name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                                    = "${var.vm1-name}-ipconfig"
    subnet_id                               = azurerm_subnet.subnet.id
    private_ip_address_allocation           = "dynamic"
    
  }

  tags = {
    project = var.costcenter
  }
}

resource "azurerm_virtual_machine" "vm-1" {
  name                  = var.vm1-name
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic-vm1-name.id]
  vm_size               = "Standard_D8s_v3"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.vm1-name}-disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.vm1-name
    admin_username = var.username
    admin_password = var.password
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }

  tags = {
    project = var.costcenter
  }
}

resource "azurerm_virtual_machine_extension" "dsc" {
    name = "ExtDSC"
    virtual_machine_id = azurerm_virtual_machine.vm-1.id
    publisher = "Microsoft.Powershell"
    type = "DSC"
    type_handler_version = "2.80"
    settings = <<SETTINGS
        {
             "configuration": {
                        "url": "https://github.com/GetVirtual/Azure-ARM/raw/master/Demo-AzureMigrate/DSC/HyperV.zip",
                        "script": "HyperV.ps1",
                        "function": "HyperV"
              }
        }
    SETTINGS
}

