output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

# REVIEW: ACR admin username output may not be required if
# admin access is disabled and managed identities are used.
output "acr_admin_username" {
  value = azurerm_container_registry.main.admin_username
}

# REVIEW: Exposing the registry login server is useful for image publishing
# and deployment validation.
output "acr_login_server" {
  value = azurerm_container_registry.main.login_server
}

# SECURITY: Removed ACR admin password output.
# Sensitive credentials should not be exposed through Terraform outputs.
#
# output "acr_admin_password" {
#   value = azurerm_container_registry.main.admin_password
# }

output "container_app_url" {
  value = "https://${azurerm_container_app.api.ingress[0].fqdn}"
}