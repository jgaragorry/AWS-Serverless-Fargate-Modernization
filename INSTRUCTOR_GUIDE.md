# 👨‍🏫 Guía del Instructor: Workshop #3

## 🎯 Objetivo Pedagógico
Enseñar la evolución de **VM (EC2)** hacia **Serverless Containers (Fargate)**, introduciendo conceptos Enterprise como **Load Balancers**, **Backend Remoto** y **FinOps**.

## 🗣️ Narrativa (Storytelling)
1.  **El Problema:** En el Workshop #2 (Docker Local) la app funcionaba, pero vivía en nuestra laptop. Si cerramos la laptop, la app muere.
2.  **La Solución Incorrecta:** Poner Docker en una EC2 (volvemos a administrar S.O. y parches).
3.  **La Solución Enterprise:** Usar **AWS Fargate**. AWS maneja el servidor, nosotros solo le damos el contenedor.

## 🔑 Puntos Técnicos Clave (A destacar en clase)

### 1. Seguridad en Docker (DevSecOps)
* **Mencionar:** "Si ven scripts viejos en internet, usan `docker login` con tuberías. Eso es inseguro".
* **Nosotros:** Usamos `amazon-ecr-credential-helper`. La contraseña nunca toca el disco duro.

### 2. El Backend Remoto (Trabajo en Equipo)
* **Explicar:** "¿Por qué corremos el script `00_init` primero?".
* **Razón:** Para no guardar el estado de Terraform (`terraform.tfstate`) en local. Si trabajamos en equipo, necesitamos que ese archivo viva en S3 y tenga bloqueo (Locking) para no sobrescribirnos el trabajo.

### 3. Application Load Balancer (ALB)
* **Pregunta frecuente:** "¿Por qué no usamos la IP pública del contenedor directo?".
* **Respuesta:** Porque en producción las IPs de los contenedores cambian y son efímeras. El ALB es la "Puerta Principal" estable, segura y capaz de manejar HTTPS (SSL) en el futuro.

### 4. FinOps (Costo)
* Hacer énfasis en el script `99_destroy.sh`.
* Explicar que el **ALB cobra por hora**. Dejarlo encendido una semana cuesta dinero real. Un buen ingeniero DevOps siempre limpia su entorno de pruebas.

## ⚠️ Troubleshooting (Posibles Errores)

* **Error:** *Terraform `No changes` o `Variable undeclared`.*
    * **Causa:** El alumno creó los archivos vacíos pero no los guardó, o no creó el archivo `terraform.tfvars`.
    * **Solución:** Revisar contenido de `main.tf` y verificar existencia de `terraform.tfvars`.

* **Error:** *Docker push falla / Access Denied.*
    * **Causa:** Las credenciales de AWS CLI expiraron o no están configuradas.
    * **Solución:** Correr `aws sts get-caller-identity` para verificar sesión.

* **Warning:** *Deprecated dynamodb_table.*
    * **Nota:** Ya lo solucionamos en el script usando S3 Native Locking, pero si alguien usa una versión muy vieja de Terraform, podría fallar. Requerimos Terraform >= 1.5.0.
