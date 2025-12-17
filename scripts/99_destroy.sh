#!/bin/bash

# --- IDEMPOTENCIA DE RUTAS ---
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."

echo "🔥 INICIANDO PROTOCOLO DE DESTRUCCIÓN TOTAL (FinOps) 🔥"
echo "⚠️  ADVERTENCIA: Esto eliminará TODOS los recursos del taller."
echo "   Tienes 5 segundos para cancelar (Ctrl+C)..."
sleep 5

# PASO 1: Destruir la Infraestructura Principal (App, ALB, ECS)
# Es CRÍTICO hacer esto primero mientras el backend (S3) aún existe.
if [ -d "$PROJECT_ROOT/terraform" ]; then
    echo "--- 1. Destruyendo Capa de Aplicación (Terraform Main) ---"
    cd "$PROJECT_ROOT/terraform"
    
    # Verificamos si se ha inicializado terraform antes de intentar destruir
    if [ -d ".terraform" ]; then
        terraform destroy -auto-approve
    else
        echo "⏩ Terraform no inicializado en main, saltando..."
    fi
else
    echo "⏩ Carpeta terraform no encontrada."
fi

# PASO 2: Eliminar Repositorios ECR (Forzado)
# Terraform a veces no puede borrar ECR si tienen imágenes dentro.
echo "--- 2. Limpiando Repositorios Docker (ECR) ---"
REGION="us-east-1"
REPO_NAME="aws-serverless-w3-repo"
# El comando '|| true' asegura la idempotencia: si falla (porque no existe), el script sigue.
aws ecr delete-repository --repository-name $REPO_NAME --region $REGION --force || true

# PASO 3: Destruir el Backend (S3 y DynamoDB)
# Esto se hace AL FINAL.
echo "--- 3. Destruyendo Backend de Seguridad (Bootstrap) ---"
cd "$PROJECT_ROOT/bootstrap"
if [ -d ".terraform" ]; then
    terraform destroy -auto-approve
fi

# PASO 4: Limpieza de archivos locales
echo "--- 4. Limpiando archivos locales generados ---"
rm -f "$PROJECT_ROOT/terraform/backend.tf"
rm -rf "$PROJECT_ROOT/terraform/.terraform"
rm -f "$PROJECT_ROOT/terraform/.terraform.lock.hcl"
rm -rf "$PROJECT_ROOT/bootstrap/.terraform"
rm -f "$PROJECT_ROOT/bootstrap/.terraform.lock.hcl"

echo "✅ ¡Limpieza Completada! No se generarán más costos."
