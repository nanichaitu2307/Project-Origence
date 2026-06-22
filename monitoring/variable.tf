# SECURITY: Datadog API key should be injected from
# Azure Key Vault, 
# or environment variables.

variable "datadog_api_key" {
  description = "Datadog API Key"
  type        = string
  sensitive   = true
}

# SECURITY: Datadog application key should be injected from
# Azure Key Vault,
# or environment variables.

variable "datadog_app_key" {
  description = "Datadog Application Key"
  type        = string
  sensitive   = true
}