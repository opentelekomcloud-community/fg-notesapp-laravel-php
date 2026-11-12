# prefix will be prepended to all resource names
variable "prefix" {
  type        = string
  description = "Prefix to be prepended to all resource names"
  default     = "set in variables.tfvars"
}

variable "description" {
  type        = string
  description = "Description of the deployment"
  default     = "set in variables.tfvars"
}

# FunctionGraph: Function name
variable "function_name" {
  type        = string
  description = "Name of the FunctionGraph function"
  default     = "set in variables.tfvars"
}

variable "image_url" {
  type        = string
  description = "URL of the Docker image for the FunctionGraph function"
  default     = "set in Makefile"
}

# Resource tag:
variable "tag_app_group" {
  type        = string
  description = "Application group tag for the resources"
  default     = "set in variables.tfvars"
}

variable "RUN_MIGRATIONS" {
  type        = string
  description = "Flag to indicate whether to run database migrations"
  default     = "set in variables.tfvars"
}

variable "API_GATEWAY_INSTANCE_ID" {
  type        = string
  description = "ID of the API Gateway instance"
  default     = "set in variables.auto.tfvars"
}

variable "APP_KEY" {
  type        = string
  description = "Application key for the Laravel application"
  default     = "set in variables.auto.tfvars"
}

variable "DB_HOST" {
  type        = string
  description = "Hostname or IP address of the database server"
  default     = "set in variables.auto.tfvars"
}

variable "DB_PORT" {
  type        = string
  description = "Port for the database connection"
  default     = "5432"
}

variable "DB_DATABASE" {
  type        = string
  description = "Name of the database"
  default     = "set in variables.auto.tfvars"
}

variable "DB_USERNAME" {
  type        = string
  description = "Username for the database user"
  default     = "set in variables.auto.tfvars"
}

variable "DB_PASSWORD" {
  type        = string
  description = "Password for the database user"
  default     = "set in variables.auto.tfvars"
}

variable "ADMIN_EMAILS" {
  type        = string
  description = "comma separated list of emails for admin users"
  default     = " set in variables.auto.tfvars"
}

variable "VPC_ID" {
  type        = string
  description = "ID of the VPC"
  default     = "set in variables.auto.tfvars"
}

variable "NETWORK_ID" {
  type        = string
  description = "ID of the subnet within the VPC"
  default     = "set in variables.auto.tfvars"
}
