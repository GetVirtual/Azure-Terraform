provider "azurerm" { 
    subscription_id = "180b44f4-1d54-4817-87ef-22ca8f374006"
}


# West Europe Vars

resource "azurerm_resource_group" "rg-we" {
  name     = "TerraFormLBDemo-WE"
  location = "West Europe"

  tags {
provider "azurerm" { 
    subscription_id = "180b44f4-1d54-4817-87ef-22ca8f374006"
}

variable "vm-we-1" {
  default = "WestEuropeWeb1"  
}

variable "vm-we-2" {
  default = "WestEuropeWeb2"  
}

# Cost Center Tag
variable "costcenter" {
  default = "LBDemo"  
}

# West Europe

resource "azurerm_resource_group" "rg-we" {
  name     = "TerraFormLBDemo-WE"
  location = "West Europe"

  tags {
    project = "${var.costcenter}"
  }
}

resource "azurerm_virtual_network" "vnet-we" {
  name                = "virtualNetwork1"
  resource_group_name = "${azurerm_resource_group.rg-we.name}"
  location            = "${azurerm_resource_group.rg-we.location}"
  address_space       = ["10.1.0.0/16"]

  tags {
    project = "${var.costcenter}"
  }
}

resource "azurerm_subnet" "subnet-we" {
  name                 = "subnet1"
  resource_group_name  = "${azurerm_resource_group.rg-we.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet-we.name}"
  address_prefix       = "10.1.1.0/24"
}

# Load Balancer West Europe
resource "azurerm_public_ip" "lb-we-publicip" {
  name                         = "lb-we-publicip"
  location                     = "${azurerm_resource_group.rg-we.location}"
  resource_group_name          = "${azurerm_resource_group.rg-we.name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "jlo-we-lb"
}

resource "azurerm_lb" "lb-we" {
  name                = "lb-we"
  location            = "${azurerm_resource_group.rg-we.location}"
  resource_group_name = "${azurerm_resource_group.rg-we.name}"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.lb-we-publicip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "lb-we-pool" {
  resource_group_name = "${azurerm_resource_group.rg-we.name}"
  loadbalancer_id     = "${azurerm_lb.lb-we.id}"
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_rule" "lb-we-rule" {
  resource_group_name            = "${azurerm_resource_group.rg-we.name}"
  loadbalancer_id                = "${azurerm_lb.lb-we.id}"
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "PublicIPAddress"

  backend_address_pool_id       = "${azurerm_lb_backend_address_pool.lb-we-pool.id}"
  probe_id                      = "${azurerm_lb_probe.lb-we-probe.id}"
}

resource "azurerm_lb_probe" "lb-we-probe" {
  resource_group_name = "${azurerm_resource_group.rg-we.name}"
  loadbalancer_id     = "${azurerm_lb.lb-we.id}"
  name                = "RDP-running-probe"
  port                = 3389
}

# VMs West Europe

resource "azurerm_availability_set" "avset-we" {
  name                = "northeurope-availabilityset"
  location            = "${azurerm_resource_group.rg-we.location}"
  resource_group_name = "${azurerm_resource_group.rg-we.name}"
  managed             = true

  tags {
    project = "${var.costcenter}"
  }
}

resource "azurerm_network_interface" "nic-vm-we-1" {
  name                = "${var.vm-we-1}-nic"
  location            = "${azurerm_resource_group.rg-we.location}"
  resource_group_name = "${azurerm_resource_group.rg-we.name}"

  ip_configuration {
    name                          = "${var.vm-we-1}-ipconfig"
    subnet_id                     = "${azurerm_subnet.subnet-we.id}"
    private_ip_address_allocation = "dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.lb-we-pool.id}"]
  }

  tags {
    project = "${var.costcenter}"
  }
}

resource "azurerm_virtual_machine" "vm-we-1" {
  name                  = "${var.vm-we-1}"
  location              = "${azurerm_resource_group.rg-we.location}"
  resource_group_name   = "${azurerm_resource_group.rg-we.name}"
  network_interface_ids = ["${azurerm_network_interface.nic-vm-we-1.id}"]
  vm_size               = "Standard_B2ms"
  availability_set_id   = "${azurerm_availability_set.avset-we.id}"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.vm-we-1}-disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.vm-we-1}"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_windows_config {

  }

  tags {
    project = "${var.costcenter}"
  }
}

resource "azurerm_network_interface" "nic-vm-we-2" {
  name                = "${var.vm-we-2}-nic"
  location            = "${azurerm_resource_group.rg-we.location}"
  resource_group_name = "${azurerm_resource_group.rg-we.name}"

  ip_configuration {
    name                          = "${var.vm-we-2}-ipconfig"
    subnet_id                     = "${azurerm_subnet.subnet-we.id}"
    private_ip_address_allocation = "dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.lb-we-pool.id}"]
  }

  tags {
    project = "${var.costcenter}"
  }
}

resource "azurerm_virtual_machine" "vm-we-2" {
  name                  = "${var.vm-we-2}"
  location              = "${azurerm_resource_group.rg-we.location}"
  resource_group_name   = "${azurerm_resource_group.rg-we.name}"
  network_interface_ids = ["${azurerm_network_interface.nic-vm-we-2.id}"]
  vm_size               = "Standard_B2ms"
  availability_set_id   = "${azurerm_availability_set.avset-we.id}"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.vm-we-2}-disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.vm-we-2}"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_windows_config {

  }

  tags {
    project = "${var.costcenter}"
  }
}


# Traffic Manager

resource "azurerm_resource_group" "rg-tm" {
  name     = "TerraFormLBDemo-TM"
  location = "West Europe"
}

resource "azurerm_traffic_manager_profile" "tm-profile" {
p