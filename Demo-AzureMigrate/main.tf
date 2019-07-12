provider "azurerm" { 
    subscription_id = "180b44f4-1d54-4817-87ef-22ca8f374006"
}

variable "vm-dc" {
  default = "HCE-DC"  
}

variable "vm-file" {
  default = "HCE-File"  
}

variable "vm-hyperv" {
  default = "HCE-HyperV"  
}

variable "costcenter" {
  default = "TF-HybridCloud-Env"  
}

resource "azurerm_resource_group" "rg" {
  name     = "TF-HybridCloud-Env"
  location = "West Europe"

  tags {
    project = "${var.costcenter}"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "HybridCloud-VNET"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
  address_space       = ["10.0.0.0/16"]

  tags {
    project = "${var.costcenter}"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet1"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_network_interface" "nic-vm-hyperv" {
  name                = "${var.vm-hyperv}-nic"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "${var.vm-hyperv}-ipconfig"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "dynamic"
  }

  tags {
    project = "${var.costcenter}"
  }
}

resource "azurerm_virtual_machine" "vm-hyperv" {
  name                  = "${var.vm-hyperv}"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.nic-vm-hyperv.id}"]
  vm_size               = "Standard_D8_v3"
  
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.vm-hyperv}-disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.vm-hyperv}"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_windows_config {

  }

  tags {
    project = "${var.costcenter}"
  }
}


resource "azurerm_virtual_machine_extension" "vm-hyperv-dsc" {
  name                 = "DSC"
  location             = "${azurerm_resource_group.rg.location}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_machine_name = "${var.vm-hyperv}"
  publisher            = "Microsoft.Powershell"
  type                 = "DSC"
  type_handler_version = "2.76"
  depends_on           = ["azurerm_virtual_machine.vm-hyperv"]

  settings = <<SETTINGS
        {
            "properties": {
                "publisher": "Microsoft.Powershell",
                "type": "DSC",
                "typeHandlerVersion": "2.76",
                "autoUpgradeMinorVersion": true,
                "settings": {
                    "configuration": {
                        "url": "https://github.com/GetVirtual/Terraform-Templates/raw/master/Demo-AzureMigrate/DSC/HyperV.zip",
                        "script": "HyperV.ps1",
                        "function": "HyperV"
                    }
                }
            }
        }
    SETTINGS

  
}