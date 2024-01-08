resource "azurecaf_name" "private_dns_zone_group" {

  for_each      = var.dns_zone_group_name_use_caf ? local.mssql_servers_merged : {}
  name          = "sqlServer"
  resource_type = "azurerm_private_dns_zone_group"
  prefixes      = var.caf_prefixes
  suffixes      = []
  use_slug      = true
  clean_input   = true
  separator     = ""
  random_length = 3
}

module "private_endpoint_server" {
  source = "WeAreRetail/private-endpoint/azurerm"
  providers = {
    azurerm = azurerm.link_sub
  }
  for_each = local.mssql_servers_merged

  resource_group_name = var.resource_group_name
  subnet_id           = var.endpoint_subnet_id
  resource_id         = each.value.id
  caf_prefixes        = var.caf_prefixes
  description         = var.description

  private_dns_zone_group = [{
    name = var.dns_zone_group_name_use_caf ? azurecaf_name.private_dns_zone_group[each.key].result : "default",
    ids  = [var.private_dns_zone_id]
  }]

  subresource_names = ["sqlServer"]
}
