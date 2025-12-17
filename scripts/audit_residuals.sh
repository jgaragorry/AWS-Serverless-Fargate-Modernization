#!/bin/bash

# ====================================================
# 🕵️‍♂️ AUDITOR DE RESIDUOS (AWS CLEANUP CHECK)
# Proyecto: AWS Serverless Fargate Modernization
# Objetivo: Verificar que NO pagaremos ni un centavo más.
# ====================================================

PROJECT_PREFIX="aws-serverless-w3"
REGION="us-east-1"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔍 Iniciando Auditoría Forense en Región: $REGION${NC}"
echo "   Buscando recursos con patrón: '$PROJECT_PREFIX'..."
echo "----------------------------------------------------"

scan_resource() {
    SERVICE=$1
    DESC=$2
    CMD=$3
    
    echo -n "   Verificando $DESC... "
    # Ejecutamos el comando y filtramos por el nombre del proyecto
    RESULT=$(eval $CMD)
    
    if [ -z "$RESULT" ]; then
        echo -e "${GREEN}✅ LIMPIO${NC}"
    else
        echo -e "${RED}⚠️  RESIDUO DETECTADO:${NC}"
        echo "$RESULT"
    fi
}

# 1. COMPUTO & CONTENEDORES
scan_resource "ECS Cluster" "Clústeres ECS" \
"aws ecs list-clusters --region $REGION --query 'clusterArns[?contains(@, \`$PROJECT_PREFIX\`)]' --output text"

scan_resource "ECS Task Def" "Definiciones de Tarea (Versiones)" \
"aws ecs list-task-definitions --region $REGION --family-prefix ${PROJECT_PREFIX}-task --query 'taskDefinitionArns[]' --output text"

scan_resource "ECR" "Repositorios Docker" \
"aws ecr describe-repositories --region $REGION --query 'repositories[?contains(repositoryName, \`$PROJECT_PREFIX\`)].repositoryName' --output text 2>/dev/null"

# 2. RED & BALANCEO
scan_resource "ALB" "Balanceadores de Carga" \
"aws elbv2 describe-load-balancers --region $REGION --query 'LoadBalancers[?contains(LoadBalancerName, \`$PROJECT_PREFIX\`)].LoadBalancerName' --output text"

scan_resource "Target Groups" "Grupos de Destino (ALB)" \
"aws elbv2 describe-target-groups --region $REGION --query 'TargetGroups[?contains(TargetGroupName, \`$PROJECT_PREFIX\`)].TargetGroupName' --output text"

scan_resource "VPC" "VPCs del Proyecto" \
"aws ec2 describe-vpcs --region $REGION --filters Name=tag:Name,Values=${PROJECT_PREFIX}* --query 'Vpcs[].VpcId' --output text"

scan_resource "Security Groups" "Grupos de Seguridad" \
"aws ec2 describe-security-groups --region $REGION --filters Name=group-name,Values=${PROJECT_PREFIX}* --query 'SecurityGroups[].GroupId' --output text"

# 3. ALMACENAMIENTO & ESTADO
scan_resource "S3" "Buckets S3 (Backend)" \
"aws s3api list-buckets --query 'Buckets[?contains(Name, \`$PROJECT_PREFIX\`)].Name' --output text"

scan_resource "DynamoDB" "Tablas DynamoDB (Locks)" \
"aws dynamodb list-tables --region $REGION --query 'TableNames[?contains(@, \`$PROJECT_PREFIX\`)]' --output text"

# 4. IDENTIDAD & LOGS
scan_resource "IAM Roles" "Roles de Ejecución" \
"aws iam list-roles --query 'Roles[?contains(RoleName, \`$PROJECT_PREFIX\`)].RoleName' --output text"

scan_resource "CloudWatch" "Grupos de Logs" \
"aws logs describe-log-groups --region $REGION --query 'logGroups[?contains(logGroupName, \`$PROJECT_PREFIX\`)].logGroupName' --output text"

echo "----------------------------------------------------"
echo -e "${YELLOW}🏁 Auditoría Finalizada.${NC}"
echo "   Si todo está en VERDE, tu billetera está a salvo."
