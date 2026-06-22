environment = "prod"

location = "West US"

# SECURITY: Removed hardcoded database password.
# Value should be supplied through secure pipeline variables
# or Azure Key Vault.
sql_admin_password = "REPLACE_WITH_SECRET"

# SECURITY: Removed hardcoded API key.
# Value should be supplied through secure pipeline variables
# or Azure Key Vault.
api_key = "REPLACE_WITH_SECRET"

app_name = "myapp"

# SECURITY: Removed hardcoded Datadog API key.
# Value should be supplied through secure pipeline variables
# or Azure Key Vault.
datadog_api_key = "REPLACE_WITH_SECRET"