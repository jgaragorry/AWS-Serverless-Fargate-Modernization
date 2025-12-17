# ☁️ Workshop #3: Modernización Enterprise a Serverless (Fargate + ALB)

![Terraform](https://img.shields.io/badge/Terraform-IaC-purple?style=for-the-badge&logo=terraform)
![AWS](https://img.shields.io/badge/AWS-Fargate-orange?style=for-the-badge&logo=amazon-aws)
![Docker](https://img.shields.io/badge/Docker-Container-blue?style=for-the-badge&logo=docker)
![Status](https://img.shields.io/badge/Status-Educational-green?style=for-the-badge)

## 📋 Descripción Ejecutiva

Bienvenido a la **Fase 3** DevOps. Tras haber "dockerizado" nuestra aplicación legacy en el taller anterior, ahora la desplegaremos en una arquitectura **Enterprise Grade** utilizando **AWS Fargate** (Serverless Compute).

A diferencia de soluciones básicas, utilizaremos un **Application Load Balancer (ALB)** como único punto de entrada, garantizando alta disponibilidad, seguridad y escalabilidad automática.

> **Concepto Clave:** No gestionaremos servidores (EC2). AWS gestionará la infraestructura subyacente por nosotros (Serverless).

### 🏛️ Arquitectura de Referencia

```ascii
      INTERNET
         |
    [ Usuarios ]
         |
   +-----+---------------------------+
   | AWS VPC (Virtual Cloud)         |
   |                                 |
   |   [ ALB - Load Balancer ]       | <--- Único Punto de Entrada (Puerto 80)
   |             |                   |
   |      (Reglas de Tráfico)        |
   |             v                   |
   |   +---------+---------+         |
   |   | ECS Cluster       |         |
   |   |  [ Fargate Task ] | <--- Contenedor Docker (App Legacy)
   |   |  (IP Privada)     |      (Sin acceso directo desde Internet)
   |   +---------+---------+         |
   +-------------|-------------------+
                 |
        [ AWS ECR Registry ] <--- Nuestra Imagen Docker
```

---

## 🛡️ Gobernanza y FinOps (Etiquetado)

Para asegurar la trazabilidad de costos y cumplimiento, Terraform aplicará automáticamente los siguientes Tags a **todos** los recursos.

| Key | Valor Estándar | Justificación FinOps |
| :--- | :--- | :--- |
| `Project` | `Modernization-W3` | Centro de costos del proyecto. |
| `Environment` | `Production` | Define políticas de retención. |
| `Owner` | `Estudiante` | Responsable técnico. |
| `ManagedBy` | `Terraform` | Indica automatización total. |
| `CostCenter` | `DevOps-Training` | Auditoría de facturación. |

---

## 🛠️ Requisitos Técnicos

* **AWS CLI v2** instalado y configurado.
* **Terraform** >= 1.5.0.
* **Docker** corriendo localmente.
* **Amazon ECR Credential Helper** (Requisito de Seguridad DevSecOps).

---

## 🚀 Instrucciones de Ejecución

### FASE 0: Cimientos de Seguridad (Backend)
Antes de desplegar, creamos una bóveda aislada para el estado de Terraform.

```bash
cd scripts
chmod +x *.sh
./00_init_backend.sh
```
*Esto configura un Bucket S3 con Encriptación y Bloqueo Nativo (S3 Native Locking) para proteger el `terraform.tfstate`.*

### FASE 1: Construcción y Publicación (ECR)
Construimos la imagen Docker (Alpine) y la subimos al registro privado.

```bash
./01_deploy_image.sh
```
> **¡IMPORTANTE!** Al finalizar, copia la URL de la imagen que te mostrará el script.

### FASE 2: Despliegue de Infraestructura (IaC)
Desplegaremos la red, el balanceador y el clúster ECS.

1.  Ve al directorio de Terraform:
    ```bash
    cd ../terraform
    ```
2.  Crea el archivo de variables secretas `terraform.tfvars`:
    ```hcl
    aws_region   = "us-east-1"
    project_name = "aws-serverless-w3"
    app_image    = "PEGA_TU_URL_DE_IMAGEN_AQUI"
    ```
3.  Despliega:
    ```bash
    terraform init
    terraform plan -out=serverless.tfplan
    terraform apply "serverless.tfplan"
    ```

### FASE 3: Validación
Al finalizar, Terraform mostrará la URL del Balanceador (Output: `alb_dns_name`).

```bash
# Ejemplo de validación
curl http://<ALB_DNS_NAME>
```
*Abre esa URL en tu navegador para ver tu aplicación corriendo.*

---

## 🧹 FinOps: Protocolo de Limpieza

**¡CRÍTICO!** El ALB tiene costo por hora. Ejecuta este script inmediatamente al terminar el taller para detener la facturación.

```bash
cd ../scripts
./99_destroy.sh
```
*Este script eliminará la App, las imágenes de Docker y el Backend de seguridad, dejando tu cuenta limpia ($0.00).*

---

## 👨‍🏫 Instructor y Contacto

**Jorge Garagorry** | *Cloud & DevOps Instructor*

* 💼 **LinkedIn:** [linkedin.com/in/jgaragorry](https://linkedin.com/in/jgaragorry)
* 🎥 **YouTube:** [youtube.com/@Softraincorp](https://youtube.com/@Softraincorp)
* 🎵 **TikTok:** [tiktok.com/@softtraincorp](https://tiktok.com/@softtraincorp)
* 👥 **Comunidad WhatsApp:** [Unirme al Grupo](https://chat.whatsapp.com/ENuRMnZ38fv1pk0mHlSixa)
* 📧 **Consultoría:** +56 956744034

> *Este material es parte de un workshop educativo diseñado para enseñar mejores prácticas de DevOps e IaC.*
