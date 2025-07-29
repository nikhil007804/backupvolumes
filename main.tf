# IAM Role for AWS Backup
resource "aws_iam_role" "backup_role" {
  name = "pratyusha-backup-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "backup.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

# Backup Vault
resource "aws_backup_vault" "vault" {
  name = var.backup_vault_name
}

# Backup Plan
resource "aws_backup_plan" "plan" {
  name = var.backup_plan_name
  rule {
    rule_name         = var.backup_rule_name
    target_vault_name = aws_backup_vault.vault.name
    schedule          = "cron(0 3 * * ? *)" # 3 AM UTC daily
    lifecycle {
      delete_after = 30
    }
  }
}

# Backup Selection
resource "aws_backup_selection" "selection" {
  name         = "pratyusha-ebs-selection"
  iam_role_arn = aws_iam_role.backup_role.arn
  plan_id      = aws_backup_plan.plan.id
  resources    = [var.ebs_volume_arn]
}