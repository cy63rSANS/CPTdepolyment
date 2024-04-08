locals {
  userdata = base64encode(file("./cloud-init/cpt.txt"))
}

resource "random_string" "vmpassword" {
  length           = 15
  special          = true
  numeric          = true
  upper            = true
  override_special = "!@$%^&(){}[]"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2

}

resource azurerm_network_interface cpthost {
	 name = "CPThost"
	 location = var.Location
	 resource_group_name = var.ResG
	 enable_ip_forwarding = false
	 enable_accelerated_networking  = false
	 ip_configuration {
		 name = "CPThost"
		 subnet_id = "${azurerm_subnet.CPText.id}"
		 private_ip_address = "172.20.0.200"
		 private_ip_address_allocation = "Static"
		 primary = true
		 public_ip_address_id = "${azurerm_public_ip.CPTpip.id}"
		}
	tags = { 
	    Environment = var.Environment
	    Author = "Cy63rSi"
	} 
}

resource "azurerm_virtual_machine" "cpthost" {
  name                = "CPThost"
  resource_group_name = var.ResG
  location            = var.Location
  vm_size             = "Standard_B2s"
  network_interface_ids =  [azurerm_network_interface.cpthost.id]
  
  os_profile_linux_config {
    disable_password_authentication = false
  }

  os_profile {
    computer_name = "CPThost"
    admin_username = "netadmin"
    admin_password = "${random_string.vmpassword.id}"
    custom_data = local.userdata
  }

  storage_os_disk {
      name          = "cpt"
      create_option = "FromImage"
      disk_size_gb  = "32"
      os_type       = "Linux"
      caching       = "ReadWrite"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "22.04.202204200"
  }

}
output "vm_password" {
  value = random_string.vmpassword.id
}