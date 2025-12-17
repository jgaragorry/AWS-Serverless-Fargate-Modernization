#!/bin/bash

# ==========================================
# GESTOR DE ESTRUCTURA DE PROYECTO (Idempotente)
# Proyecto: AWS Serverless Fargate Modernization
# ==========================================

# Nombre del directorio raíz del proyecto
PROJECT_ROOT="AWS-Serverless-Fargate-Modernization"

echo "🚀 Iniciando configuración de estructura para: $PROJECT_ROOT"

# 1. Crear Directorios (mkdir -p es nativamente idempotente)
echo "📂 Verificando directorios..."
mkdir -p "$PROJECT_ROOT/app/src"
mkdir -p "$PROJECT_ROOT/terraform"
mkdir -p "$PROJECT_ROOT/scripts"
echo "   ✅ Directorios listos."

# Función para crear archivo solo si no existe
create_file_if_missing() {
    local file_path="$1"
    if [ ! -f "$file_path" ]; then
        touch "$file_path"
        echo "   ✨ Creado: $file_path"
    else
        echo "   ⏩ Omitido (Ya existe): $file_path"
    fi
}

# 2. Crear Archivos Base (Terraform)
echo "📄 Verificando archivos Terraform..."
create_file_if_missing "$PROJECT_ROOT/terraform/main.tf"
create_file_if_missing "$PROJECT_ROOT/terraform/variables.tf"
create_file_if_missing "$PROJECT_ROOT/terraform/outputs.tf"
create_file_if_missing "$PROJECT_ROOT/terraform/provider.tf"

# 3. Crear Archivos Base (App)
echo "🐳 Verificando archivos de Aplicación..."
create_file_if_missing "$PROJECT_ROOT/app/Dockerfile"
# Creamos un index.html básico solo para que no esté vacío
if [ ! -f "$PROJECT_ROOT/app/src/index.html" ]; then
    echo "<h1>Hola desde AWS Fargate!</h1>" > "$PROJECT_ROOT/app/src/index.html"
    echo "   ✨ Creado: app/src/index.html (con contenido demo)"
else
    echo "   ⏩ Omitido (Ya existe): app/src/index.html"
fi

# 4. Crear Scripts
echo "🛠️ Verificando Scripts..."
create_file_if_missing "$PROJECT_ROOT/scripts/01_deploy_image.sh"
create_file_if_missing "$PROJECT_ROOT/scripts/99_destroy.sh"
# Damos permisos de ejecución de una vez (esto no daña nada si ya los tiene)
chmod +x "$PROJECT_ROOT/scripts/"*.sh

# 5. Archivos Raíz
echo "root Verificando archivos raíz..."
create_file_if_missing "$PROJECT_ROOT/README.md"

# .gitignore (Pre-poblado si no existe)
if [ ! -f "$PROJECT_ROOT/.gitignore" ]; then
cat <<EOT >> "$PROJECT_ROOT/.gitignore"
# Terraform
.terraform/
*.tfstate
*.tfstate.backup
*.tfplan
.terraform.lock.hcl

# Sistema
.DS_Store
EOT
    echo "   ✨ Creado: .gitignore (con reglas estándar)"
else
    echo "   ⏩ Omitido (Ya existe): .gitignore"
fi

echo ""
echo "✅ ¡Estructura completada con éxito!"
echo "   Entra al proyecto con: cd $PROJECT_ROOT"
