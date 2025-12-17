# 📘 RUNBOOK: AWS Serverless Fargate Modernization

Este documento detalla el procedimiento exacto para desplegar, validar y destruir la infraestructura del Workshop #3.

**Tiempo estimado:** 45 - 60 Minutos.
**Costo:** ~$0.50 USD (si se destruye al finalizar).

---

## ✅ Prerrequisitos
1.  **AWS CLI v2** instalado y configurado (`aws configure`).
2.  **Terraform** >= 1.5.0.
3.  **Docker Desktop/Engine** corriendo.
4.  **Amazon ECR Credential Helper** instalado (Requisito DevSecOps).

---

## 🔁 FASE 0: Cimientos y Seguridad (Backend)
**Objetivo:** Crear una "bóveda" aislada (S3) para guardar el estado de Terraform y asegurar idempotencia.

1.  Navegar a la carpeta de scripts:
    ```bash
    cd scripts
    chmod +x *.sh
    ```
2.  Ejecutar el inicializador de backend:
    ```bash
    ./00_init_backend.sh
    ```
    > **Resultado esperado:**
    > * Se crea Bucket S3 (Encriptado) y Tabla DynamoDB (Locking, opcional/legacy).
    > * Se genera automáticamente el archivo `terraform/backend.tf`.
    > * Mensaje final: `✨ Backend configurado exitosamente.`

---

## 🐳 FASE 1: Artefactos de Software (Docker & ECR)
**Objetivo:** Empaquetar la aplicación Legacy y subirla a un registro privado seguro.

1.  Ejecutar el script de despliegue de imagen:
    ```bash
    ./01_deploy_image.sh
    ```
2.  **¡IMPORTANTE!** Al finalizar, el script mostrará una URL. **CÓPIALA.**
    * *Ejemplo:* `533267117128.dkr.ecr.us-east-1.amazonaws.com/aws-serverless-w3-repo:latest`

---

## 🏗️ FASE 2: Infraestructura como Código (Terraform)
**Objetivo:** Desplegar la Red (VPC), Balanceador (ALB) y el Clúster (Fargate).

1.  Ir al directorio de Terraform:
    ```bash
    cd ../terraform
    ```
2.  Crear el archivo de secretos (No se sube a Git):
    ```bash
    vi terraform.tfvars
    ```
    *Contenido (Pega tu URL de imagen aquí):*
    ```hcl
    aws_region   = "us-east-1"
    project_name = "aws-serverless-w3"
    app_image    = "PEGA_AQUI_LA_URL_DEL_PASO_ANTERIOR"
    ```
3.  Inicializar y Aplicar:
    ```bash
    terraform init
    terraform plan -out=serverless.tfplan
    terraform apply "serverless.tfplan"
    ```
    > **Tiempo de espera:** 3 a 5 minutos (mientras se provisiona el ALB).

---

## 🌐 FASE 3: Validación Enterprise
**Objetivo:** Verificar que la aplicación es accesible vía Internet a través del Balanceador.

1.  Al terminar el `apply`, Terraform mostrará un output verde:
    ```text
    alb_dns_name = "[http://aws-serverless-w3-alb-XXXX.us-east-1.elb.amazonaws.com](http://aws-serverless-w3-alb-XXXX.us-east-1.elb.amazonaws.com)"
    ```
2.  Abrir esa URL en el navegador.
3.  **Éxito:** Debes ver el mensaje "Hola desde AWS Fargate!" (o el index de tu app).

---

## 🧹 FASE 4: Protocolo FinOps (Limpieza)
**Objetivo:** Eliminar TODOS los recursos para detener la facturación inmediatamente.

1.  Volver a la carpeta de scripts:
    ```bash
    cd ../scripts
    ```
2.  Ejecutar la destrucción total:
    ```bash
    ./99_destroy.sh
    ```
    > **Acciones del script:**
    > 1. Destruye la App (Fargate, ALB, VPC).
    > 2. Fuerza el borrado del repo ECR (Imágenes).
    > 3. Destruye el Backend de Seguridad (S3).
    > 4. Borra archivos locales temporales (`.terraform`).

**Estado Final:** Costo $0.00.
