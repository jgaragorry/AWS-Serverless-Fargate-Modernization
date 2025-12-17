# 🏆 Tecnologías, Arquitectura y Mejores Prácticas

Este documento detalla las decisiones técnicas tomadas para el **Workshop #3**, alineadas con el marco de trabajo **AWS Well-Architected Framework**.

## 🛠️ Stack Tecnológico

| Tecnología | Rol | ¿Por qué la usamos? |
| :--- | :--- | :--- |
| **Terraform** | IaC (Infrastructure as Code) | Para automatizar la creación de recursos de forma predecible e idempotente. Versión >= 1.5.0. |
| **AWS Fargate** | Serverless Compute | Elimina la gestión de parches y servidores (EC2). Pagamos solo por el tiempo de CPU/RAM usado. |
| **AWS ALB** | Application Load Balancer | Punto de entrada único, maneja tráfico HTTP/HTTPS y permite auto-escalado seguro. |
| **Docker** | Containerization | Empaquetado inmutable de la aplicación. "Build once, run anywhere". |
| **Amazon ECR** | Container Registry | Repositorio privado y seguro para nuestras imágenes Docker (integración nativa IAM). |
| **Alpine Linux** | Base OS Image | Sistema operativo minimalista (5MB) para reducir superficie de ataque y tiempos de despliegue. |

---

## 🛡️ DevSecOps: Seguridad Integrada

Para este taller, hemos aplicado principios de **Seguridad por Diseño**:

### 1. Gestión de Identidad (Zero Trust)
* **No Hardcoded Credentials:** Eliminamos el uso de contraseñas en texto plano en scripts. Utilizamos `amazon-ecr-credential-helper` para autenticación segura en memoria.
* **IAM Roles (Least Privilege):** Fargate utiliza roles de ejecución (`execution_role`) con permisos mínimos necesarios (solo pull de ECR y envío de logs).

### 2. Protección del Estado (State Security)
* **Remote Backend:** El estado de Terraform (`terraform.tfstate`) **NUNCA** se guarda en local. Vive en un Bucket S3 encriptado.
* **Encryption at Rest:** El Bucket S3 usa encriptación AES-256 forzada.
* **State Locking:** Implementamos **S3 Native Locking** para evitar corrupción de datos si dos ingenieros despliegan al mismo tiempo.

### 3. Aislamiento de Red
* **Security Groups:** Arquitectura de "Defensa en Profundidad".
    * El **ALB** solo acepta tráfico en puerto 80 desde Internet (`0.0.0.0/0`).
    * El **Contenedor** solo acepta tráfico proveniente del ALB (Nadie puede atacar la IP del contenedor directamente).

---

## 💰 FinOps: Optimización de Costos

La nube no es gratis. Hemos aplicado controles para evitar sorpresas en la facturación:

1.  **Tagging Strategy:** Todos los recursos se etiquetan automáticamente con `CostCenter`, `Owner` y `Project`. Esto permite auditoría de costos granular.
2.  **Resource Right-Sizing:** Usamos Fargate con `0.25 vCPU` y `512 MB` RAM, suficiente para la demo sin sobre-aprovisionar.
3.  **Lifecycle Management:** Scripts automatizados (`99_destroy.sh`) para la eliminación total de recursos huérfanos (ALB, ECR, S3) al finalizar el laboratorio.

---

## 🚀 Pro-Tips para el Instructor (El "Factor Wow")

* **Idempotencia:** Nuestros scripts pueden ejecutarse 100 veces sin romper nada. Si el recurso existe, se omite o actualiza; nunca se duplica.
* **Inmutabilidad:** Una vez que construimos la imagen Docker, es la misma que corre en local y en producción. Se acabaron los problemas de "En mi máquina funciona".
* **Automatización:** Generamos el archivo `backend.tf` dinámicamente. Evitamos el error humano de copiar/pegar IDs de buckets.
