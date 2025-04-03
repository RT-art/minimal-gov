########################################
# Metadata
########################################
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
  description = "A mapping of tags to assign to the resources."
  type        = map(any)
}

########################################
## S3
########################################

variable "versioning_enabled" {
  description = "Enable versioning. Once you version-enable a bucket, it can never return to an unversioned state."
  type        = bool
}

variable "server_side_encryption_configuration" {
  description = "Map containing server-side encryption configuration."
  type        = any
}

variable "control_object_ownership" {
  description = "Whether to manage S3 Bucket Ownership Controls on this bucket."
  type        = bool
}
########################################
## DynamoDB
########################################

variable "hash_key" {
  description = "The attribute to use as the hash (partition) key."
  type        = string
}

variable "dynamodb_billing_mode" {
  description = "Billing mode for the DynamoDB table (PROVISIONED or PAY_PER_REQUEST)."
  type        = string
  default     = "PAY_PER_REQUEST" # オンデマンドを推奨
}

variable "dynamodb_deletion_protection" {
  description = "Enable deletion protection for the DynamoDB table."
  type        = bool
  default     = true # 誤削除防止のため推奨
}

variable "dynamodb_pitr_enabled" {
  description = "Enable Point-in-Time Recovery for the DynamoDB table."
  type        = bool
  default     = true # データ保護のため推奨
}

variable "dynamodb_sse_enabled" {
  description = "Enable Server-Side Encryption for the DynamoDB table."
  type        = bool
  default     = true # 保管時の暗号化のため推奨
}

variable "point_in_time_recovery_enabled" {
  description = "Whether to enable point-in-time recovery"
  type        = bool
}

variable "stream_enabled" {
  description = "Indicates whether Streams are to be enabled (true) or disabled (false)."
  type        = bool
}

variable "ttl_enabled" {
  description = "Indicates whether ttl is enabled"
  type        = bool
}

variable "server_side_encryption_enabled" {
  description = "Whether or not to enable encryption at rest using an AWS managed KMS customer master key (CMK)"
  type        = bool
}

variable "create_table" {
  description = "Controls if DynamoDB table and associated resources are created"
  type        = bool
}

variable "autoscaling_enabled" {
  description = "Whether or not to enable autoscaling. See note in README about this setting"
  type        = bool
}