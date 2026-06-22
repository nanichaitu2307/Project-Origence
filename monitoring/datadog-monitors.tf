terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}

provider "datadog" {

  # SECURITY: Removed hardcoded credentials.
  # In production these values should be supplied through
  # Azure Key Vault,
  # or environment variables.

  api_key = var.datadog_api_key
  app_key = var.datadog_app_key

  api_url = "https://api.datadoghq.com/"
}

resource "datadog_monitor" "cpu_high" {
  name = "High CPU"
  type = "metric alert"

  # FIX: Improved alert message with actionable guidance.
  message = "High CPU utilization detected. Investigate resource consumption, application performance, and scaling requirements."

  # FIX: Added tags to improve monitor organization and filtering.
  tags = ["service:myapp-api", "environment:prod"]

  # FIX: Increased evaluation window and threshold to reduce alert fatigue
  # caused by short-lived CPU spikes.
  query = "avg(last_5m):avg:azure.containerapp.cpu_usage{container_app_name:ca-myapp-api} > 80"

  monitor_thresholds {
    critical = 80
  }
}

resource "datadog_monitor" "response_time" {
  name = "Slow Response Times"
  type = "metric alert"

  # FIX: Improved alert message with actionable troubleshooting guidance.
  message = "Response time degradation detected. Investigate application latency, downstream dependencies, and database performance."

  # FIX: Added tags to improve monitor organization and filtering.
  tags = ["service:myapp-api", "environment:prod"]

  # FIX: Increased evaluation window to reduce alert noise caused by
  # short-lived latency spikes.
  query = "avg(last_5m):avg:trace.http.request.duration{service:myapp-api} > 1.0"

  monitor_thresholds {
    critical = 1.0
  }
}

resource "datadog_monitor" "error_log" {
  name = "High Error Rate"
  type = "log alert"

  # FIX: Provide more actionable troubleshooting guidance.
  message = "Application error rate exceeded threshold. Review application logs, recent deployments, and downstream service dependencies."

  # FIX: Added tags to improve monitor organization and filtering.
  tags = ["service:myapp-api", "environment:prod"]

  # FIX: Alert only when errors are sustained to reduce noise
  # from isolated application failures.
  query = "logs(\"status:error AND service:myapp-api\").index(\"*\").rollup(\"count\").last(\"5m\") > 5"

  monitor_thresholds {
    critical = 5
  }
}

resource "datadog_monitor" "container_running" {
  name = "Container Running"
  type = "metric alert"

  # FIX: Improve alert message to provide actionable troubleshooting guidance.
  message = "Container application has no running instances. Investigate service availability, recent deployments, and platform health."

  tags = ["service:myapp-api", "environment:prod"]

  # FIX: Monitor the minimum number of running instances to detect complete service outages.
  query = "avg(last_5m):min:azure.containerapp.running_instances{container_app_name:ca-myapp-api} < 1"

  monitor_thresholds {
    critical = 1
  }
}

resource "datadog_dashboard" "app_dashboard" {
  title = "My App Dashboard"

  # FIX: Use a more descriptive dashboard description to clarify its operational purpose.
  description = "Operational dashboard for application performance, resource utilization, request volume, and error monitoring."

  layout_type = "ordered"


  widget {
    timeseries_definition {
      title = "CPU"
      request {
        q            = "avg:azure.containerapp.cpu_usage{container_app_name:ca-myapp-api}"
        display_type = "line"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Memory"
      request {
        q            = "avg:azure.containerapp.memory_usage{container_app_name:ca-myapp-api}"
        display_type = "line"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Request Count"
      request {
        q            = "sum:trace.http.request.hits{service:myapp-api}.as_count()"
        display_type = "bars"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Error Count"
      request {
        q            = "sum:logs(status:error AND service:myapp-api).rollup(sum, 300)"
        display_type = "line"
      }
    }
  }

  # REVIEW: Consider adding latency and availability widgets to improve operational visibility.
}
