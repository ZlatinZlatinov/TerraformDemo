variable "resource_group_name" {
  type        = string
  description = "Actual Name of the Resource Group"
}

variable "resource_group_location" {
  type        = string
  description = "Actual Location of the Resource Group"
}

variable "appservice_plan_name" {
  type        = string
  description = "Actual Name of the App Service Plan"
}

variable "appservice_name" {
  type        = string
  description = "Actual Name of the App Service"
}

variable "sql_server_name" {
  type        = string
  description = "Actual Name of the Sql Server"
}

variable "sql_database_name" {
  type        = string
  description = "Actual Name of the SQL Database"
}

variable "sql_admin_login_name" {
  type        = string
  description = "Actual Name of the SQL Admin Login Name"
}

variable "sql_admin_login_password" {
  type        = string
  description = "Actual Name of the SQL Admin Login Password"
}

variable "firewall_rule_name" {
  type        = string
  description = "Actual Name of the Firewall Rule"
}

variable "github_repo_url" {
  type        = string
  description = "URL of the GitHub repo"
}

variable "subscription_id" {
  type        = string
  description = "Subscription ID"
}