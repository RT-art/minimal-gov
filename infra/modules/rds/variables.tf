variable "region" {
  type        = string
  description = "AWS region"
}

variable "app_name" {
  type        = string
  description = "Application name"
}

variable "env" {
  type        = string
  description = "Environment name (dev/stg/prod)"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "engine" {
  type        = string
  description = "Database engine (postgres, mysql, etc.)"
}

variable "engine_version" {
  type        = string
  description = "Database engine version. If null, latest compatible minor for the family is selected."
  default     = null
}

variable "preferred_engine_versions" {
  type        = list(string)
  description = "Preference order for engine versions when engine_version is null."
  default     = ["16.*", "15.*", "14.*"]
}

variable "instance_class" {
  type        = string
  description = "RDS instance class"
}

variable "db_name" {
  type        = string
  description = "Initial database name"
}

variable "username" {
  type        = string
  description = "Master username"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for RDS"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for RDS subnet group"
}

variable "db_port" {
  type        = number
  description = "Database port (5432 for Postgres, 3306 for MySQL, etc.)"
  default     = 5432
}

variable "allowed_sg_id" {
  type        = string
  description = "Security group ID allowed to access the RDS. Null if none."
  default     = null
}
