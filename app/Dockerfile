# Usamos una imagen base ultra-ligera (aprox 5MB)
FROM nginx:alpine

# Copiamos nuestro sitio web al directorio estándar de Nginx
COPY src/index.html /usr/share/nginx/html/index.html

# Documentamos que el contenedor escucha en el puerto 80
EXPOSE 80

# Comando de arranque (Nginx en primer plano)
CMD ["nginx", "-g", "daemon off;"]
