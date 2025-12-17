#!/bin/bash
set -e

# --- IDEMPOTENCIA DE RUTAS ---
# Detectamos dónde está este script para navegar con precisión
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."
BOOTSTRAP_DIR="$PROJECT_ROOT/bootstrap"
TERRAFORM_DIR="$PROJECT_ROOT/terraform"

echo "🔒 --- FASE 0: Bootstrapping del Backend Remoto ---"

# Verificamos que Terraform esté instalado
if ! command -v terraform &> /dev/null; then
    echo "❌ Error: Terraform no está instalado."
    exit 1
fi

# Navegamos a la carpeta bootstrap de forma segura
cd "$BOOTSTRAP_DIR"

echo "    Inicializando Terraform en: $(pwd)"
# init es idempotente, upgrade asegura que no haya conflictos de plugins
terraform init -upgrade

echo "    Aplicando configuración (Idempotente)..."
terraform apply -auto-approve

# Capturamos outputs
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
TABLE_NAME=$(terraform output -raw dynamodb_table_name)
REGION="us-east-1"

echo "✅ Infraestructura de Backend verificada."
echo "   Bucket: $BUCKET_NAME"
echo "   Table:  $TABLE_NAME"

# Generamos backend.tf MODERNIZADO (Native Locking)
BACKEND_FILE="$TERRAFORM_DIR/backend.tf"

echo "📝 Actualizando configuración en: $BACKEND_FILE"

# Usamos cat para garantizar que el archivo tenga SIEMPRE el contenido correcto
cat <<EOT > "$BACKEND_FILE"
# ESTE ARCHIVO FUE GENERADO AUTOMÁTICAMENTE
# CONFIGURACIÓN DE BACKEND REMOTO (S3 Native Locking)

terraform {
  backend "s3" {
    bucket       = "$BUCKET_NAME"
    key          = "global/s3/terraform.tfstate"
    region       = "$REGION"
    # dynamodb_table = "$TABLE_NAME"  <-- ELIMINADO POR DEPRECACIÓN
    use_lockfile = true              # <-- NUEVO ESTÁNDAR
    encrypt      = true
  }
}
EOT

echo "✨ Backend configurado exitosamente (S3 Native Locking)."
