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