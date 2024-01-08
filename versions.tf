terraform {
  required_version = " >= 1.3.0"
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = ">= 3.14"
      configuration_aliases = [azurerm.db_sub, azurerm.link_sub]
    }

    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = ">= 1.2.25"
    }
  }
}
