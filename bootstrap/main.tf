provider "aws" {
  region = "us-east-1"
}

variable "project_name" {
  default = "aws-serverless-w3"
}

# Generamos un ID aleatorio para que el nombre del Bucket sea ÚNICO mundialmente
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# --- 1. S3 BUCKET (Para guardar el tfstate) ---
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-state-${random_id.bucket_suffix.hex}"
  
  # FinOps: Evitar borrado accidental de la "memoria" del proyecto
  force_destroy = true 

  tags = {
    Name        = "Terraform Remote State"
    Environment = "Management"
    Project     = "Bootstrap-Backend"
    ManagedBy   = "Terraform"
  }
}

# Seguridad: Versionado (Para recuperar estados previos si algo explota)
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Seguridad: Encriptación en reposo (Compliance)
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# --- 2. DYNAMODB TABLE (Para el Locking) ---
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${var.project_name}-locks"
  billing_mode = "PAY_PER_REQUEST" # FinOps: Solo pagas si usas terraform
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "Management"
    Project     = "Bootstrap-Backend"
  }
}

# --- OUTPUTS (Para que el script sepa qué creó) ---
output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.name
}
