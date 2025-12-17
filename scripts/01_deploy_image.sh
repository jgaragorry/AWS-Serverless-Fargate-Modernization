#!/bin/bash
set -e

# --- IDEMPOTENCIA DE RUTAS (Navegación Robusta) ---
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR/.."
APP_DIR="$PROJECT_ROOT/app"

REGION="us-east-1"
REPO_NAME="aws-serverless-w3-repo"

echo "🐳 --- FASE 1: Build & Push de Imagen Docker ---"

# 1. Validaciones previas
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker no está instalado o no se está ejecutando."
    echo "   Por favor inicia Docker Desktop/Engine."
    exit 1
fi

# Obtenemos ID de cuenta dinámicamente
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URL="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"
FULL_IMAGE_NAME="$ECR_URL/$REPO_NAME:latest"

echo "    Cuenta AWS: $ACCOUNT_ID"
echo "    Región:     $REGION"

# 2. Login ECR (Pipe seguro de contraseña)
# ❌ ESTO YA NO ES NECESARIO (Y ERA INSEGURO)
# echo "🔑 Autenticando Docker con ECR..."
# aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin "$ECR_URL"

# 3. Crear Repo (Idempotente + Tags FinOps)
echo "📦 Verificando repositorio ECR..."
# Verificamos existencia antes de intentar crear para no generar error
if ! aws ecr describe-repositories --repository-names "$REPO_NAME" --region "$REGION" > /dev/null 2>&1; then
    echo "    Creando repositorio '$REPO_NAME'..."
    aws ecr create-repository \
        --repository-name "$REPO_NAME" \
        --region "$REGION" \
        --tags Key=Project,Value=Modernization-W3 Key=Environment,Value=Production Key=ManagedBy,Value=Script
else
    echo "    ⏩ El repositorio ya existe (Omitiendo creación)."
fi

# 4. Build & Tag
echo "🏗️  Construyendo imagen local (Forzando AMD64 para Fargate)..."
# Usamos ruta absoluta APP_DIR para evitar errores de "context not found"
docker build --platform linux/amd64 -t "$REPO_NAME" "$APP_DIR"

echo "🏷️  Etiquetando imagen para AWS..."
docker tag "$REPO_NAME:latest" "$FULL_IMAGE_NAME"

# 5. Push
echo "🚀 Subiendo imagen a la nube..."
docker push "$FULL_IMAGE_NAME"

echo ""
echo "✅ ¡Imagen Desplegada Exitosamente!"
echo "---------------------------------------------------"
echo "👇 COPIA ESTA URL (La necesitarás para Terraform):"
echo ""
echo "   $FULL_IMAGE_NAME"
echo ""
echo "---------------------------------------------------"
