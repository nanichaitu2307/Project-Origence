# CHANGES.md

## Platform Engineering Review Summary

This review focused on identifying security vulnerabilities, infrastructure risks, deployment concerns, and operational improvements across the application code, Terraform infrastructure, and Azure DevOps pipeline.

The objective was to prioritize the highest-impact issues, implement practical fixes where appropriate, and document additional recommendations for future improvements.

------------------------------------------------------------------------------

1. Application Code Review (Program.cs)

Findings

Security Findings

1. Hardcoded Password

The application contains a hardcoded password used for encryption.

Risk:
- Secrets should not be stored in source control.
- Anyone with repository access can view the credential.

Recommendation:
- Store secrets in configuration files, environment variables, or a secure secret management solution.

------------------------------------------------------------------------------

2. Deprecated Encryption Algorithm (DES)

The application uses DES for encryption and decryption.

Risk:
- DES is considered insecure and deprecated.
- Modern applications should use AES.

Recommendation:
- Replace DES with AES and manage encryption keys securely.

------------------------------------------------------------------------------

3. XML External Entity (XXE) Vulnerability

The XML parser allowed DTD processing and external entity resolution.

Risk:
- XXE vulnerabilities can expose local files.
- XXE can also be used for SSRF and denial-of-service attacks.

Fix Implemented:

Updated XML parsing configuration:

    DtdProcessing = DtdProcessing.Prohibit
    XmlResolver = null

This prevents XML External Entity attacks by disabling DTD processing and external entity resolution.

------------------------------------------------------------------------------

Reliability Findings

4. HttpClient Usage

A new HttpClient instance is created for every API request.

Risk:
- Can lead to socket exhaustion under heavy load.
- Reduces application efficiency.

Recommendation:
- Reuse HttpClient instances through a shared or static implementation.

------------------------------------------------------------------------------

5. Missing Response Validation

HTTP responses are processed without validating status codes.

Risk:
- Failed requests may be processed as successful responses.
- Could lead to unexpected application behavior.

Recommendation:
- Validate responses using EnsureSuccessStatusCode() or equivalent handling.

------------------------------------------------------------------------------

6. Missing Exception Handling

External API calls do not include exception handling.

Risk:
- Network failures could terminate the application.
- Troubleshooting becomes more difficult.

Recommendation:
- Add exception handling and logging around external API calls.

------------------------------------------------------------------------------

7. Edition Processing Logic Bug

Original Code:

    foreach (var edition in titleResponse.Docs[0].EditionKeys)

Issue:
- The application always processed editions from the first search result.

Fix Implemented:

    foreach (var edition in book.EditionKeys)

This ensures the application processes editions belonging to the current book being evaluated.

------------------------------------------------------------------------------

2. Terraform Review

Findings and Fixes

1. Hardcoded Resource Names

Issue:
- Resource names were tied to a specific production deployment.

Fix Implemented:

    name = "${var.app_name}-${var.environment}-rg"

Benefits:
- Supports multiple environments using the same codebase.
- Improves reusability and maintainability.

------------------------------------------------------------------------------

2. Hardcoded Azure Region

Issue:
- Location values were previously hardcoded.

Fix Implemented:

    location = var.location

------------------------------------------------------------------------------

3. Hardcoded Secrets

Issue:
- Database passwords, API keys, and Datadog API keys were stored directly in Terraform files.

Fix Implemented:

- Removed hardcoded secrets.
- Marked sensitive variables appropriately.

Example:

    variable "api_key" {
      type      = string
      sensitive = true
    }

------------------------------------------------------------------------------

4. Missing Variable Documentation

Issue:
- Variables lacked descriptions and type definitions.

Fix Implemented:

- Added descriptions.
- Added explicit variable types.
- Improved readability and validation.

------------------------------------------------------------------------------

5. ACR Admin Access Enabled

Issue:
- Azure Container Registry admin access was enabled.

Risk:
- Creates unnecessary credential exposure.

Fix Implemented:

    admin_enabled = false

Recommendation:
- Use managed identities or service principals instead.

------------------------------------------------------------------------------

6. Insufficient Log Retention

Issue:
- Log Analytics retention was only 7 days.

Fix Implemented:

    retention_in_days = 30

Benefits:
- Better troubleshooting.
- Improved audit and incident investigation support.

------------------------------------------------------------------------------

7. Availability Concerns

Issue:
- Container App could scale down to zero.

Fix Implemented:

    min_replicas = 1
    max_replicas = 3

Benefits:
- Reduces cold starts.
- Improves application availability.

------------------------------------------------------------------------------

8. Sensitive Outputs

Issue:
- Terraform outputs exposed registry credentials.

Fix Implemented:

- Removed credential outputs.
- Added review comments explaining the security risk.

------------------------------------------------------------------------------

9. Environment Configuration Issue

Issue:

    environment = "prod"

was used in nonprod.tfvars.

Fix Implemented:

    environment = "nonprod"

------------------------------------------------------------------------------

3. Azure DevOps Pipeline Review

Findings and Fixes

1. Hardcoded Secrets

Issue:
- ACR password
- SQL password
- Datadog API key

were stored directly in pipeline variables.

Risk:
- Secrets exposed in source control.

Fix Implemented:

- Removed hardcoded secrets.
- Added review comments recommending secure variable groups or Azure Key Vault.

------------------------------------------------------------------------------

2. Mutable Image Tag

Issue:

    imageTag: latest

Risk:
- Deployments are not traceable.
- Different deployments may use different container images.

Fix Implemented:

- Replaced latest with build-specific image tags.

------------------------------------------------------------------------------

3. Missing Terraform Validation

Issue:
- Terraform formatting and validation were not performed before deployment.

Fix Implemented:

Recommended adding:

    terraform fmt -check
    terraform validate

before Terraform plan and apply stages.

------------------------------------------------------------------------------

4. Production Deployment Safety

Issue:
- Production deployments lacked approval controls.

Recommendation:

- Configure Azure DevOps Environment Approvals.
- Require manual approval before production deployment.

------------------------------------------------------------------------------

5. Deployment Notifications

Issue:
- No deployment notifications existed.

Recommendation:

Send deployment notifications using:

- Microsoft Teams
- Email
- Azure DevOps notifications

------------------------------------------------------------------------------

4. Additional Improvements Recommended

Application

- Replace DES with AES encryption.
- Implement shared HttpClient usage.
- Add request timeouts.
- Add structured logging.
- Add exception handling around API requests.
- Add input validation.

Terraform

- Integrate Azure Key Vault.
- Use managed identities for ACR authentication.
- Add private networking controls.
- Add additional tagging standards.

Pipeline

- Add security scanning.
- Add automated testing stages.
- Add deployment rollback strategy.
- Improve artifact retention and auditing.

Monitoring

- Add alert tuning.
- Add SLO/SLI monitoring.
- Add service health dashboards.
- Add incident runbook references.

------------------------------------------------------------------------------


------------------------------------------------------------------------------

4. Monitoring Review (datadog-monitors.tf)

Findings and Fixes

1. Hardcoded Datadog Credentials

Issue:
- Datadog API and Application keys were hardcoded in the provider configuration.

Risk:
- Credentials could be exposed through source control.
- Unauthorized access to Datadog monitoring resources.

Fix Implemented:

Removed hardcoded credentials and replaced them with Terraform variables.

Example:

provider "datadog" {
    api_key = var.datadog_api_key
    app_key = var.datadog_app_key
}

------------------------------------------------------------------------------

2. Sensitive Monitoring Variables

Issue:
- Monitoring credentials were not protected as sensitive values.

Fix Implemented:

Created monitoring/variables.tf and defined secure variables.

Example:

variable "datadog_api_key" {
    description = "Datadog API Key"
    type        = string
    sensitive   = true
}

variable "datadog_app_key" {
    description = "Datadog Application Key"
    type        = string
    sensitive   = true
}

Benefits:
- Prevents accidental exposure through Terraform output and logs.
- Aligns with infrastructure security best practices.

------------------------------------------------------------------------------

3. Monitor Alert Quality Improvements

Issue:
- Existing alerts provided limited troubleshooting guidance.

Fix Implemented:

Updated monitor messages with actionable operational guidance.

Example:

message = "High CPU utilization detected. Investigate resource consumption, application performance, and scaling requirements."

Benefits:
- Faster incident response.
- Better operational visibility.
- Improved troubleshooting experience.

------------------------------------------------------------------------------

4. Alert Fatigue Reduction

Issue:
- Monitoring thresholds and evaluation windows were too aggressive and could generate unnecessary alerts.

Fix Implemented:

CPU Monitor:

    avg(last_5m) > 80

Response Time Monitor:

    avg(last_5m) > 1.0

Error Rate Monitor:

    errors > 5 within 5 minutes

Benefits:
- Reduces noise from short-lived spikes.
- Improves signal-to-noise ratio.
- Helps operations teams focus on actionable alerts.

------------------------------------------------------------------------------

5. Monitor Tagging

Issue:
- Monitors lacked tags for filtering and organization.

Fix Implemented:

tags = [
    "service:myapp-api",
    "environment:prod"
]

Benefits:
- Improved monitor organization.
- Easier dashboard filtering.
- Better alert routing capabilities.

------------------------------------------------------------------------------

6. Service Availability Monitoring

Issue:
- No monitor existed to detect complete application outages.

Fix Implemented:

Added container instance availability monitoring.

Example:

query = "avg(last_5m):min:azure.containerapp.running_instances{container_app_name:ca-myapp-api} < 1"

Benefits:
- Detects complete service outages.
- Improves application availability monitoring.

------------------------------------------------------------------------------

7. Dashboard Improvements

Issue:
- Dashboard lacked documentation and operational context.

Fix Implemented:

Added descriptive dashboard documentation.

Example:

description = "Operational dashboard for application performance, resource utilization, request volume, and error monitoring."

Additional dashboard coverage includes:

- CPU utilization
- Memory utilization
- Request volume
- Error volume

Recommendation:

Consider adding:
- Latency dashboards
- Availability dashboards
- SLO/SLI tracking
- Error budget reporting

------------------------------------------------------------------------------



Review Summary

Files Reviewed

- Program.cs
- terraform/main.tf
- terraform/variables.tf
- terraform/outputs.tf
- terraform/configuration/nonprod.tfvars
- terraform/configuration/prod.tfvars
- pipeline/azure-pipelines.yml

Key Fixes Implemented

Application
- XXE vulnerability mitigated.
- Edition processing logic corrected.

Terraform
- Removed hardcoded secrets.
- Disabled ACR admin access.
- Added sensitive variables.
- Increased log retention.
- Added parameterized resource naming.
- Improved scaling configuration.
- Removed sensitive outputs.

Pipeline
- Removed hardcoded credentials.
- Replaced mutable image tags.
- Added Terraform validation recommendations.
- Added production deployment governance recommendations.

The review focused on addressing the highest-impact security, reliability, and operational risks while documenting additional improvements that would be implemented in a full production hardening effort.