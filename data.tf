locals {
  region          = var.disaster_recovery ? "DISASTER_RECOVERY" : "MAIN"
  region_computed = var.fog_enabled ? var.region_main : local.region
}

# All the SQL servers in the target subscription deployed in the main region with the required tags.
data "azurerm_resources" "sql_server" {
  type     = "Microsoft.Sql/servers"
  provider = azurerm.db_sub

  required_tags = {
    A_INFRA_REGION = local.region_computed
    A_PROJECT      = var.targetdb_project
    A_ENVIRONMENT  = upper(var.environment)
    SERVER_USAGE   = var.targetserver_usage
  }
}

# All the SQL servers in the target subscription deployed in the DR region with the required tags.
data "azurerm_resources" "sql_server_fog" {
  type     = "Microsoft.Sql/servers"
  provider = azurerm.db_sub

  count = var.fog_enabled ? 1 : 0

  required_tags = {
    A_INFRA_REGION = var.region_dr
    A_PROJECT      = var.targetdb_project
    A_ENVIRONMENT  = upper(var.environment)
    SERVER_USAGE   = var.targetserver_usage
  }
}

# All the SQL Databases in the target subscription deployed in the main region with the required tags.
data "azurerm_resources" "sql_database" {
  type     = "Microsoft.Sql/servers/databases"
  provider = azurerm.db_sub

  required_tags = {
    A_INFRA_REGION = local.region_computed
    A_PROJECT      = var.targetdb_project
    A_ENVIRONMENT  = upper(var.environment)
  }
}

# All the SQL Databases in the target subscription.
# The replicated database doesn't have tags.
data "azurerm_resources" "sql_database_fog" {
  type     = "Microsoft.Sql/servers/databases"
  provider = azurerm.db_sub
}

locals {
  # A map with all the main SQL Servers
  mssql_servers = {
    for resource in flatten(data.azurerm_resources.sql_server[*].resources) : resource.name => resource
  }

  # If FOG is enable. A map with all the servers in the DR region matching the main tags.
  mssql_servers_fog = !var.fog_enabled ? {} : {
    for resource in flatten(data.azurerm_resources.sql_server_fog[0][*].resources) : resource.name => resource
  }

  # Merged map with main and fog servers. For endpoints creation.
  mssql_servers_merged = var.create_endpoints ? merge(local.mssql_servers, local.mssql_servers_fog) : {}

  # Lists with all the SQL Servers names.
  mssql_servers_name_list     = [for name, resource in local.mssql_servers : name]
  mssql_servers_fog_name_list = !var.fog_enabled ? [] : [for name, resource in local.mssql_servers_fog : name]

  # A map with custom the full database name as key (theservername/thedatabasename). The value contains the resources returned
  # by the data source with two added properties: server_name and database_name.
  # Limited to the databases hosted on the previously found servers.
  sql_databases = {
    for resource in flatten(data.azurerm_resources.sql_database[*].resources) : resource.name => merge(
      resource,
      {
        server_name   = split("/", resource.name)[0],
        database_name = split("/", resource.name)[1],
      }
    )
    if contains(local.mssql_servers_name_list, split("/", resource.name)[0])
  }

  # A list with all the database names on the main region servers.
  sql_databases_list = [for k, v in local.sql_databases : v.database_name]

  # If FOG is enable. A map with custom the full database name in the DR region as key (theservername/thedatabasename). The value contains the resources returned
  # by the data source with two added properties: server_name and database_name.
  # Limited to the databases hosted on the previously found servers and with the same name as in the main region.
  sql_databases_fog = !var.fog_enabled ? {} : {
    for resource in flatten(data.azurerm_resources.sql_database_fog[*].resources) : resource.name => merge(
      resource,
      {
        server_name   = split("/", resource.name)[0],
        database_name = split("/", resource.name)[1],
      }
    )
    if contains(local.mssql_servers_fog_name_list, split("/", resource.name)[0]) && contains(local.sql_databases_list, split("/", resource.name)[1])
  }
}

# Data source for the found SQL Servers in the main region.
data "azurerm_mssql_server" "sql_servers" {
  provider = azurerm.db_sub
  for_each = local.mssql_servers

  name                = each.key
  resource_group_name = split("/", each.value.id)[4]
}

# Data source for the found SQL Servers in the DR region.
data "azurerm_mssql_server" "sql_servers_fog" {
  provider = azurerm.db_sub
  for_each = local.mssql_servers_fog

  name                = each.key
  resource_group_name = split("/", each.value.id)[4]
}

locals {

  # A map with all the main databases where the key is the full database name (theservername/thedatabasename).
  # The map will be used as an output for the module and contains all the required properties for the calling terraform code.
  sql_server_db_map = {
    for k_main, v_main in local.sql_databases : k_main => {
      server_name   = v_main.server_name,
      server_id     = data.azurerm_mssql_server.sql_servers[v_main.server_name].id,
      server_fqdn   = data.azurerm_mssql_server.sql_servers[v_main.server_name].fully_qualified_domain_name,
      database_name = v_main.database_name,
      db_usage      = coalesce(try(v_main.tags["DB_USAGE"], null), "NOT_DEFINED"),
      server_usage  = coalesce(try(data.azurerm_mssql_server.sql_servers[v_main.server_name].tags["SERVER_USAGE"], null), "NOT_DEFINED")
    }
  }

  # A map with all the main databases where the key is the full database name (theservername/thedatabasename).
  # This map also add properties specific to a FOG.
  # The map will be used as an output for the module and contains all the required properties for the calling terraform code.
  #
  # The merge is a bit tricky. It merges the map in the list. Using the list as a list of argument using the the expansion symbol (...) ([{k1=v1, k2=v2}]...)
  # https://developer.hashicorp.com/terraform/language/expressions/function-calls#expanding-function-arguments
  sql_server_db_map_with_fog = merge(flatten([
    for k_main, v_main in local.sql_databases : {
      for k_fog, v_fog in local.sql_databases_fog : k_main => {
        server_name       = v_main.server_name,
        server_name_fog   = v_fog.server_name
        server_id         = data.azurerm_mssql_server.sql_servers[v_main.server_name].id,
        server_id_fog     = data.azurerm_mssql_server.sql_servers_fog[v_fog.server_name].id,
        server_fqdn       = data.azurerm_mssql_server.sql_servers[v_main.server_name].fully_qualified_domain_name,
        server_fqdn_fog   = data.azurerm_mssql_server.sql_servers_fog[v_fog.server_name].fully_qualified_domain_name,
        server_fqdn_ha_rw = replace(data.azurerm_mssql_server.sql_servers[v_main.server_name].fully_qualified_domain_name, "sql", "sqlfg")
        server_fqdn_ha_ro = replace(replace(data.azurerm_mssql_server.sql_servers[v_main.server_name].fully_qualified_domain_name, "sql", "sqlfg"), ".database.windows.net", ".secondary.database.windows.net")
        database_name     = v_main.database_name,
        db_usage          = coalesce(try(v_main.tags["DB_USAGE"], null), "NOT_DEFINED"),
        server_usage      = coalesce(try(data.azurerm_mssql_server.sql_servers[v_main.server_name].tags["SERVER_USAGE"], null), "NOT_DEFINED")
      }
      if v_main.database_name == v_fog.database_name
    }
  ])...)

}
