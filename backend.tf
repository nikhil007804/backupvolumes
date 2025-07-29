terraform {
  backend "s3" {
    bucket = "terraform-state-pratyushaa-backup-hey"
    key    = "backup-volumes-snapshots/dev/terraform.tfstate"
    region = "us-east-1"
  }
}