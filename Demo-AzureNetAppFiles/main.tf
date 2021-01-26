provider "azurerm" {
  subscription_id = var.subid
  features {}
  version = "=2.17.0"
  }

resource "azurerm_resource_group" "rg" {
  name     = var.rgname
  location = "West Europe"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-anf"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.100.0/23"]
}

resource "azurerm_subnet" "subnetanf" {
  name                 = "subnet-anf"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.101.0/24"

  delegation {
    name = "netapp"

    service_delegation {
      name    = "Microsoft.Netapp/volumes"
      actions = ["Microsoft.Network/networkinterfaces/*", "Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "subnetclients" {
  name                 = "subnet-clients"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "10.0.100.0/24"
}

resource "azurerm_netapp_account" "netapp-account" {
  name                = "netappaccount"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_netapp_pool" "netapp-pool" {
  name                = "netapppool"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_netapp_account.netapp-account.name
  service_level       = "Standard"
  size_in_tb          = 4
}

resource "azurerm_netapp_volume" "netappvolume" {
  lifecycle {
    prevent_destroy = false
  }

  name                = "netappvolume"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_netapp_account.netapp-account.name
  pool_name           = azurerm_netapp_pool.netapp-pool.name
  volume_path         = "my-unique-file-path"
  service_level       = "Standard"
  subnet_id           = azurerm_subnet.subnetanf.id
  protocols           = ["NFSv3"]
  storage_quota_in_gb = 100


}