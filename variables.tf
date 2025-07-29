variable "ebs_volume_arn" {
  description = "The ARN of the EBS volume to back up"
  type        = string
}

variable "backup_vault_name" {
  description = "Name of the AWS Backup Vault"
  type        = string
  default     = "pratyusha-backup-vault"
}

variable "backup_plan_name" {
  description = "Name of the AWS Backup Plan"
  type        = string
  default     = "pratyusha-daily-backup-plan"
}

variable "backup_rule_name" {
  description = "Name of the AWS Backup Rule"
  type        = string
  default     = "daily-backup"
}