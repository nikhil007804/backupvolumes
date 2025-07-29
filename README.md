# AWS Volume Backup Automation with Terraform & GitHub Actions

This project automates **daily Backups of an AWS  volume** using **Terraform** and **GitHub Actions**.  
It provisions all necessary AWS resources and schedules backups at **3 AM UTC**, retaining each backup for **30 days**.

---

##  Prerequisites

-  An existing EBS volume in your AWS account.  
  If not, see [How to Create an EBS Volume](#how-to-create-an-ebs-volume).
-  AWS credentials (Access Key ID and Secret Access Key) with permissions to manage IAM, EC2, and AWS Backup.
-  Terraform installed locally (for initial setup/testing).
-  A GitHub repository for this code.

---

##  How to Create an EBS Volume

**Via AWS Console**:
1. Go to the **EC2 Dashboard**.
2. Click **Volumes** under **Elastic Block Store**.
3. Click **Create Volume**, choose size/type/AZ, and click **Create**.
4. Note the **Volume ID** (e.g., `vol-0efe9d5419d6128e7`).

**Via AWS CLI**:
```bash
aws ec2 create-volume --size 8 --region us-east-1 --availability-zone us-east-1a --volume-type gp2
```

**Get the ARN for your volume**:
```bash
aws sts get-caller-identity --query Account --output text
```
Then construct:
```
arn:aws:ec2:us-east-1:YOUR_ACCOUNT_ID:volume/VOLUME_ID
```

**Example**:
```
arn:aws:ec2:us-east-1:1234571473:volume/vol-0efe9d5419d6128e7
```

---

##  How This Works

| Component         | Purpose                                                  |
|------------------|----------------------------------------------------------|
| IAM Role         | Allows AWS Backup to manage EBS backups.                 |
| Backup Vault     | Secure storage for backup snapshots.                     |
| Backup Plan      | Defines daily backup at 3 AM UTC, with 30-day retention. |
| Backup Selection | Specifies which EBS volume to back up (using ARN).       |

---

##  What Gets Created

- An IAM role (`pratyusha-backup-role`) with backup permissions.
- A backup vault named in your `terraform.tfvars`.
- A daily backup plan with 30-day retention.
- Backup selection that targets the specified EBS volume.

---

##  How to Use

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/your-repo.git
cd your-repo
```

### 2. Configure Terraform Variables

Edit `terraform.tfvars`:

```hcl
ebs_volume_arn    = "arn:aws:ec2:us-east-1:515517371473:volume/vol-0efe9d5419d6128e7"
backup_vault_name = "pratyusha-backup-vault"
backup_plan_name  = "pratyusha-daily-backup-plan"
backup_rule_name  = "daily-backup"
```

---

### 3. Add Collaborators (for repo access)

1. Go to your GitHub repo → **Settings** → **Collaborators**.
2. Click **Add People** and invite collaborators by GitHub username.

---

### 4. Add GitHub Environments for Manual Approval

1. Go to **Settings** → **Environments** → **New environment**.
2. Name it `production` (or `dev` as per your branch).
3. Add **required reviewers** to enforce approval before `terraform apply`.

---

### 5. Set Up GitHub Secrets

Go to **Settings → Secrets and variables → Actions** → New Repository Secret:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `INFRACOST_API_KEY` (get from https://dashboard.infracost.io/) 

---

### 6. Run Locally (Optional)

```bash
terraform init
terraform plan
terraform apply
```

---

##  GitHub Actions Automation

GitHub Actions (`.github/workflows/deploy.yml`) will:

- Run `terraform init`
- Run `infracost breakdown` to estimate cost
- Generate a Terraform plan
- Pause for manual approval (via environments)
- Run `terraform apply`

---

##  Cost Estimation with Infracost

Integrated with GitHub Actions:

```yaml
- name: Generate Infracost Breakdown
  run: infracost breakdown --path=. --format=json --out-file=infracost.json
```

Infracost will estimate monthly costs for your EBS backups in each PR.

---

##  Where to Check in AWS Console

| Resource         | Console Path                                      |
|------------------|---------------------------------------------------|
| IAM Role         | IAM Console → Roles → `pratyusha-backup-role`     |
| Backup Vault     | AWS Backup → Backup vaults                        |
| Backup Plan      | AWS Backup → Backup plans                         |
| Resource Assign  | Backup plan → Resource assignments                |
| Backups          | Backup vault → Recovery points                    |

---

##  Troubleshooting

###  Error: `EntityAlreadyExists: Role with name pratyusha-backup-role already exists`

This means the IAM role already exists in your AWS account.

 **Fix**:

**Option 1:** Import it into Terraform:

```bash
terraform import aws_iam_role.backup_role pratyusha-backup-role
```

**Option 2:** Delete the existing role in AWS Console → IAM → Roles → `pratyusha-backup-role`.

**Option 3:** Rename it in Terraform:

```hcl
name = "pratyusha-backup-role-unique"
```

---

##  Backup Schedule

- **Daily at 3 AM UTC**
- **Retention: 30 days**
- You can modify these values in `main.tf` inside the backup plan rule.

---
