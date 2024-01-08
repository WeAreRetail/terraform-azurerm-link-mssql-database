output "mssql_servers_fully_qualified_domain_name" {
  value = [for k, v in data.azurerm_mssql_server.sql_servers : v.fully_qualified_domain_name]
}

output "sql_servers_databases_map" {
  value = var.fog_enabled ? local.sql_server_db_map_with_fog : local.sql_server_db_map
}
