# ---------- Define the Providers  ----------
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.41.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.1"
    }
  }
}

# ---------- Configurate Providers  ----------
provider "azurerm" {
  features {}
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

provider "null" {

}

# ---------- AZURE  ----------
#Create resource group
resource "azurerm_resource_group" "dv_rg" {
  name = "david-bouman5-resource-group"
  location = "West Europe"
  tags = var.dave_tags
}

#---------- create database Cosmos service ----------
resource "azurerm_cosmosdb_account" "dv_cosmosdb" {
  name = "david-bouman5-csmosdb"
  location = azurerm_resource_group.dv_rg.location
  resource_group_name = azurerm_resource_group.dv_rg.name
  offer_type = "Standard"
  tags = var.dave_tags
  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }
  geo_location {
    location          = azurerm_resource_group.dv_rg.location
    failover_priority = 0
  }
}

#---------- NoSQL ----------
resource "azurerm_cosmosdb_sql_database" "nosql-db" {
  name = "raw-tweets-db"
  resource_group_name = azurerm_resource_group.dv_rg.name
  account_name = azurerm_cosmosdb_account.dv_cosmosdb.name
  autoscale_settings {
    max_throughput = 4000
  }
}

resource "azurerm_cosmosdb_sql_container" "nosql-table-1" {
  name = "raw-tweets"
  resource_group_name = azurerm_resource_group.dv_rg.name
  account_name = azurerm_cosmosdb_account.dv_cosmosdb.name
  database_name = azurerm_cosmosdb_sql_database.nosql-db.name
  partition_key_path = "/id"
  partition_key_version = 1
  autoscale_settings {
    max_throughput = 4000
  }
}

#---------- SQL ----------
resource "azurerm_cosmosdb_sql_database" "sql-db" {
  name = "estructured-tweets-db"
  resource_group_name = azurerm_resource_group.dv_rg.name
  account_name = azurerm_cosmosdb_account.dv_cosmosdb.name
  autoscale_settings {
    max_throughput = 4000
  }
}

resource "azurerm_cosmosdb_sql_container" "sql-table-1" {
  name = "estructured-tweets"
  resource_group_name = azurerm_resource_group.dv_rg.name
  account_name = azurerm_cosmosdb_account.dv_cosmosdb.name
  database_name = azurerm_cosmosdb_sql_database.sql-db.name
  partition_key_path = "/id"
  partition_key_version = 1
  autoscale_settings {
    max_throughput = 4000
  }
}
# #create postgresql database
  # resource "azurerm_postgresql_server" "sql-svr" {
  #   name                = "david-bouman5-postgresql-server"
  #   location            = azurerm_resource_group.dv_rg.location
  #   resource_group_name = azurerm_resource_group.dv_rg.name
  #   tags = var.dave_tags

  #   sku_name = "B_Gen5_2"

  #   storage_mb                   = 5120
  #   backup_retention_days        = 7
  #   geo_redundant_backup_enabled = false
  #   auto_grow_enabled            = true

  #   administrator_login          = "davidadmin1"
  #   administrator_login_password = "DVAdmin123%#"
  #   version                      = "9.5"
  #   ssl_enforcement_enabled      = true
  # }

  # resource "azurerm_postgresql_database" "sql-db" {
  #   name                = "estructured-tweets"
  #   resource_group_name = azurerm_resource_group.dv_rg.name
  #   server_name         = azurerm_postgresql_server.sql-svr.name
  #   charset             = "UTF8"
  #   collation           = "English_United States.1252"

  # }

# ---------- Conatiner  ----------
resource "azurerm_container_registry" "main-container" {
  name = "davidBouman5DockerContainer"
  resource_group_name = azurerm_resource_group.dv_rg.name
  location = azurerm_resource_group.dv_rg.location
  sku = "Basic"
  tags = var.dave_tags
}
#DOCKER------------------------------------------
#login not working, login before runing all of this
# resource "null_resource" "azure_login" {
#   provisioner "local-exec" {
#       command = "az login -u ${var.azure_user_email} -p ${var.azure_user_password} >> .env"
#     }
# }

resource "null_resource" "docker_login" {
  depends_on = [null_resource.azure_login]
  provisioner "local-exec" {
    command = "docker login azure --client-id ${var.azure_user_email} --client-secret ${var.azure_user_password}  --tenant-id "
  }
}

output "NOSQL_ENDPOINT" {
  value = azurerm_cosmosdb_account.dv_cosmosdb.endpoint
}

output "NOSQL_KEY" {
  value = azurerm_cosmosdb_account.dv_cosmosdb.primary_key
  sensitive = true
}

resource "null_resource" "get_nosql_credentials" {
  depends_on = [
    azurerm_cosmosdb_sql_container.nosql-table-1

  ]
  provisioner "local-exec" {
    command = "echo 'NOSQL_ENDPOINT=' $(terraform state show '') >> .env && echo 'NOSQL_KEY=' ${} >> .env"
  }
  
}

resource "null_resource" "docker_compose_up_local" {
  depends_on = [
    # null_resource.docker_login,
    azurerm_container_registry.main-container,
    azurerm_cosmosdb_sql_container.sql-table-1,
    azurerm_cosmosdb_sql_container.nosql-table-1,
    null_resource.get_nosql_credentials
  ]
  provisioner "local-exec" {
    command = "docker compose up"
  }
  provisioner "local-exec" {
    command = "docker compose down"
  }  
  provisioner "local-exec" {
    command = "docker compose push"
  }
}

resource "null_resource" "create_docker_context" {
  command = "docker context create aci twtcontext"
}