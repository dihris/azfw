# Deploy Azure Firewall PIP Prefix

resource "azurerm_public_ip_prefix" "AzureFirewallPublicIpPrefix" {
  name                = "az-fw-pip-prefix"
  location            = "westus2"
  resource_group_name = "test"
  prefix_length       = "30"
  sku                 = "Standard"
}

#Provision Public IP address for Azure Firewall from existing prefix.

resource "azurerm_public_ip" "az-fw-public-NATIP01" {
  name                = "az-fw-public-NATIP01"
  location            = "westus2"
  resource_group_name = "test"
  allocation_method   = "Static"
  sku                 = "Standard"
  public_ip_prefix_id = "${azurerm_public_ip_prefix.AzureFirewallPublicIpPrefix.id}"
}


# Deploy PaaS Services PIP Prefix

resource "azurerm_public_ip_prefix" "PaaSServicesPublicIpPrefix" {
  name                = "az-services-pip-prefix"
  location            = "$westus2"
  resource_group_name = "test"
  prefix_length       = "28"
  sku                 = "Standard"
}

#Provision Public IP address for test service from existing prefix.

resource "azurerm_public_ip" "test_net" {
  name                = "test_net"
  location            = "westus2"
  resource_group_name = "test"
  allocation_method   = "Static"
  sku                 = "Standard"
  public_ip_prefix_id = "${azurerm_public_ip_prefix.PaaSServicesPublicIpPrefix.id}"
}




# Deploy Azure Firewall

resource "azurerm_firewall" "az-fw" {
  name                = "az-fw"
  location            = "westus2"
  resource_group_name = "test"
  zones               = [1,2]

# Firewall SNAT PIP
  ip_configuration {
    name                 = azurerm_public_ip.az-fw-public-NATIP01.name
    subnet_id            = module.common.subnet-firewallsubnet_id
    public_ip_address_id = "${azurerm_public_ip.az-fw-public-NATIP01.id}"
  }

# PIP for test service
  ip_configuration {
    name                 = azurerm_public_ip.test_net.name
    public_ip_address_id = "${azurerm_public_ip.test_net.id}"
  }
}
