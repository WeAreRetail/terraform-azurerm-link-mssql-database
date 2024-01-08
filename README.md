# Azure Aware Link MSSQL Database

[![Build Status](https://dev.azure.com/weareretail/Tooling/_apis/build/status/mod_azu_databricks_data?repoName=mod_azu_link_mssql_database&branchName=master)](https://dev.azure.com/weareretail/Tooling/_build/latest?definitionId=11&repoName=mod_azu_link_mssql_database&branchName=master)[![Unilicence](https://img.shields.io/badge/licence-The%20Unilicence-green)](LICENCE)

Common Azure Terraform module to normalize the connection to storage accounts on different environments

# Usage

```hcl
module "link_mssql_database" {
  source = "WeAreRetail/link-mssql-database/azurerm"
  providers = {
    azurerm.db_sub   = azurerm.source_sub
    azurerm.link_sub = azurerm
  }

  environment         = var.environment
  targetdb_project    = local.trigram
  targetserver_usage  = local.server_usage_tag
  resource_group_name = "rg_name"
  endpoint_subnet_id  = azurerm_subnet.endpoints.id
  caf_prefixes        = module.trigram_naming.resource_prefixes
  private_dns_zone_id = module.private_dns_database.zone_id
  fog_enabled         = true
}
```

***Autogenerated file - do not edit***

#### Requirements

#### Inputs

#### Outputs

No outputs.

<!-- BEGIN_TF_DOCS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) |  >= 1.3.0 |
| <a name="requirement_azurecaf"></a> [azurecaf](#requirement\_azurecaf) | >= 1.2.25 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.14 |

#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_targetserver_usage"></a> [targetserver\_usage](#input\_targetserver\_usage) | The target server SERVER\_USAGE tag | `string` | n/a | yes |
| <a name="input_caf_prefixes"></a> [caf\_prefixes](#input\_caf\_prefixes) | Prefixes to use for caf naming. Only required when create\_endpoints is true. | `list(string)` | `[]` | no |
| <a name="input_create_endpoints"></a> [create\_endpoints](#input\_create\_endpoints) | Must the module create private enpoints to the server | `bool` | `true` | no |
| <a name="input_custom_tags"></a> [custom\_tags](#input\_custom\_tags) | The custom tags to add on the resource. | `map(string)` | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | An optional description tag | `string` | `""` | no |
| <a name="input_disaster_recovery"></a> [disaster\_recovery](#input\_disaster\_recovery) | Deploy disaster recovery infrastructure. Only specify if FOG is false. | `bool` | `false` | no |
| <a name="input_dns_zone_group_name_use_caf"></a> [dns\_zone\_group\_name\_use\_caf](#input\_dns\_zone\_group\_name\_use\_caf) | (optional) Use azurecaf\_name for Private DNS Zone Group name | `bool` | `false` | no |
| <a name="input_endpoint_subnet_id"></a> [endpoint\_subnet\_id](#input\_endpoint\_subnet\_id) | The subnet where to create the endpoint | `string` | `"endpoint_subnet_id not defined"` | no |
| <a name="input_fog_enabled"></a> [fog\_enabled](#input\_fog\_enabled) | Is the database part of a failover group (fog). If set to yes it will return the highly available endpoint and secondary endpoint. | `bool` | `false` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | The private dns zone id where to create the a record for the private endpoint | `string` | `"private_dns_zone_id not defined"` | no |
| <a name="input_region_dr"></a> [region\_dr](#input\_region\_dr) | The tag region value. Only if FOG is enabled. | `string` | `"DISASTER_RECOVERY"` | no |
| <a name="input_region_main"></a> [region\_main](#input\_region\_main) | The tag main region value. Only if FOG is enabled. | `string` | `"MAIN"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The Private Endpoint resource group name. Only required when create\_endpoints is true. | `string` | `null` | no |
| <a name="input_targetdb_project"></a> [targetdb\_project](#input\_targetdb\_project) | The target database A\_PROJECT tag | `string` | `"OPT"` | no |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_mssql_servers_fully_qualified_domain_name"></a> [mssql\_servers\_fully\_qualified\_domain\_name](#output\_mssql\_servers\_fully\_qualified\_domain\_name) | n/a |
| <a name="output_sql_servers_databases_map"></a> [sql\_servers\_databases\_map](#output\_sql\_servers\_databases\_map) | n/a |
<!-- END_TF_DOCS -->