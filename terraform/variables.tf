variable "aws_region" {
  description = "Región de AWS para el despliegue"
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefijo para nombres de recursos"
  default     = "aws-serverless-w3"
}

variable "app_image" {
  description = "URI de la imagen en ECR. El alumno debe pegar esto."
  type        = string
}

variable "app_port" {
  description = "Puerto del contenedor"
  default     = 80
}

variable "common_tags" {
  description = "Tags de Gobernanza y FinOps"
  type        = map(string)
  default = {
    Project     = "Modernization-W3"
    Environment = "Production"
    Owner       = "Student"
    ManagedBy   = "Terraform"
    CostCenter  = "DevOps-Training"
  }
}
