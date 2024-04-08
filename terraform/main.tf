resource azurerm_resource_group CPT {
	name = var.ResG
	location = var.Location
		tags = { 
			Environment = var.Environment
			Author = "Cy63rSi"
			CreatedDate = timestamp()
		}
}

resource azurerm_virtual_network CPTnet {
	name = "CPTnet"
	location = var.Location
	resource_group_name = var.ResG
	depends_on = [azurerm_resource_group.VPN]
	address_space =  ["172.20.0.0/22",] #172.20.0.0-172.20.3.255	
		tags = { 
			Environment = var.Environment
			Author = "Cy63rSi"
		}	
}

resource azurerm_subnet CPTint {
	 name = "CPT-Int"
	 virtual_network_name = "CPTnet"
	 resource_group_name = var.ResG
	 address_prefixes = ["172.20.2.0/24"]
     depends_on = [azurerm_virtual_network.CPTnet]
	 service_endpoints = ["Microsoft.Web"]

}

resource azurerm_subnet CPText {
	 name = "CPT-Ext"
	 virtual_network_name = "CPTnet"
	 resource_group_name = var.ResG
	 address_prefixes = ["172.20.0.0/24"]
	 service_endpoints = []
     depends_on = [azurerm_virtual_network.VPNnet]

} 

resource azurerm_public_ip CPTpip{
	 name = "VCPTpip"
	 location = var.Location
	 resource_group_name = var.ResG
	 sku = "Basic"
	 allocation_method   = "Dynamic"
     depends_on = [azurerm_resource_group.CPT]
}





