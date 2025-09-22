variable "env" {
  description = "The name of the environment."
  type        = string
}

variable "app_name" {
  description = "The name of the application."
  type        = string
}

variable "region" {
  description = "The AWS region this bucket should reside in."
  type        = string
}

variable "tags" {
  description = "Additional tags to merge on top of provider default_tags"
  type        = map(string)
  default     = {}
}

variable "versioning_enabled" {
  description = "Enable versioning. Once you version-enable a bucket, it can never return to an unversioned state."
  type        = bool
  default     = true
}

variable "use_kms" {
  description = "Use AWS KMS for server-side encryption instead of AES256"
  type        = bool
  default     = false
}

variable "kms_master_key_id" {
  description = "KMS key ID (if use_kms = true)"
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Whether to force destroy the bucket even if it contains objects."
  type        = bool
  default     = true
}

variable "lifecycle_days" {
  description = "Number of days to keep noncurrent versions of objects"
  type        = number
  default     = 180
}

variable "allowed_account_ids" {
  description = "AWS account IDs allowed cross-account access to this bucket (root principal)."
  type        = list(string)
  default     = []
}
